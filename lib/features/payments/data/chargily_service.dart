// lib/features/payments/data/chargily_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Chargily payment integration
class ChargilyService {
  static const String _baseUrl = 'https://pay.chargily.net/api/v2';
  final String _publicKey;
  final String _secretKey;

  ChargilyService({
    required String publicKey,
    required String secretKey,
  })  : _publicKey = publicKey,
        _secretKey = secretKey;

  /// Create a checkout session for payment
  ///
  /// Returns the checkout URL to redirect the patient to
  Future<Map<String, dynamic>> createCheckout({
    required String requestId,
    required double amount, // Total amount in DZD (negotiated + 500 DA)
    required String successUrl,
    required String failureUrl,
    required String webhookUrl,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Convert amount to cents (Chargily expects amount in cents)
      final amountInCents = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse('$_baseUrl/checkouts'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amountInCents,
          'currency': 'dzd',
          'success_url': successUrl,
          'failure_url': failureUrl,
          'webhook_url': webhookUrl,
          'metadata': {
            'homecare_request_id': requestId,
            'type': 'homecare_payment',
            ...?metadata,
          },
          'locale': 'ar', // Arabic locale for Algerian users
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ChargilyException(
          'Failed to create checkout: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      throw ChargilyException('Error creating Chargily checkout: $e');
    }
  }

  /// Process a refund
  ///
  /// Returns the refund details
  Future<Map<String, dynamic>> processRefund({
    required String checkoutId,
    required double amount,
  }) async {
    try {
      final amountInCents = (amount * 100).toInt();

      final response = await http.post(
        Uri.parse('$_baseUrl/refunds'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'checkout_id': checkoutId,
          'amount': amountInCents,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ChargilyException(
          'Failed to process refund: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      throw ChargilyException('Error processing Chargily refund: $e');
    }
  }

  /// Get checkout details
  Future<Map<String, dynamic>> getCheckout(String checkoutId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/checkouts/$checkoutId'),
        headers: {
          'Authorization': 'Bearer $_secretKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw ChargilyException(
          'Failed to get checkout: ${response.body}',
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      throw ChargilyException('Error getting Chargily checkout: $e');
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
