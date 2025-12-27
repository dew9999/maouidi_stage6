// lib/features/payments/data/chargily_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for secure Chargily payment integration via Edge Functions
///
/// This service calls Supabase Edge Functions instead of directly calling
/// Chargily API to keep the secret key secure on the server side.
class ChargilyService {
  final String _supabaseUrl;
  final String _supabaseAnonKey;

  ChargilyService({
    required String supabaseUrl,
    required String supabaseAnonKey,
  })  : _supabaseUrl = supabaseUrl,
        _supabaseAnonKey = supabaseAnonKey;

  /// Create a checkout session for payment via Edge Function
  ///
  /// This calls the `create-payment` Edge Function which securely
  /// accesses the Chargily secret key from the database.
  ///
  /// Returns the checkout URL to redirect the patient to
  Future<Map<String, dynamic>> createCheckout({
    required String requestId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/create-payment'),
        headers: {
          'Authorization': 'Bearer $_supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': requestId,
        }),
      );

      if (response.statusCode != 200) {
        final errorBody = jsonDecode(response.body);
        throw ChargilyException(
          errorBody['error'] ?? 'Failed to create checkout',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['success'] != true) {
        throw ChargilyException(
          data['error'] ?? 'Checkout creation failed',
        );
      }

      return data;
    } catch (e) {
      if (e is ChargilyException) rethrow;
      throw ChargilyException('Error creating payment checkout: $e');
    }
  }

  /// Process a refund via Edge Function
  ///
  /// This calls the `process-refund` Edge Function which:
  /// - Validates refund eligibility (100%/50%/0% based on timing)
  /// - Processes the refund via Chargily API
  /// - Updates the database
  ///
  /// Returns the refund details including eligibility and amount
  Future<Map<String, dynamic>> processRefund({
    required String requestId,
    required String cancelledBy, // 'patient' or 'partner'
    required String cancellationReason,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/functions/v1/process-refund'),
        headers: {
          'Authorization': 'Bearer $_supabaseAnonKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'requestId': requestId,
          'cancelledBy': cancelledBy,
          'cancellationReason': cancellationReason,
        }),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode != 200) {
        throw ChargilyException(
          data['error'] ?? 'Failed to process refund',
        );
      }

      return data;
    } catch (e) {
      if (e is ChargilyException) rethrow;
      throw ChargilyException('Error processing refund: $e');
    }
  }
}

/// Exception thrown by Chargily service
class ChargilyException implements Exception {
  final String message;
  ChargilyException(this.message);

  @override
  String toString() => 'ChargilyException: $message';
}
