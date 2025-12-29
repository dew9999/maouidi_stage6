// lib/features/payment/data/chargily_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'chargily_repository.g.dart';

/// Repository for interacting with Chargily payment gateway via Supabase Edge Function
class ChargilyRepository {
  final SupabaseClient _supabase;

  ChargilyRepository(this._supabase);

  /// Creates a Chargily checkout session for homecare appointments
  ///
  /// Returns the checkout URL where the user should be redirected
  ///
  /// Security: Uses database RPC which accesses secrets from app_config table
  Future<ChargilyCheckoutResponse> createCheckoutSession({
    required double amount,
    required String currency,
    required String userId,
    required String partnerId,
    required String appointmentTime,
  }) async {
    try {
      // Call database RPC instead of Edge Function
      // Secrets are securely stored in app_config table
      final response = await _supabase.rpc(
        'create_chargily_checkout',
        params: {
          'amount_arg': amount,
          'currency_arg': currency,
          'user_id_arg': userId,
          'partner_id_arg': partnerId,
          'appointment_time_arg': appointmentTime,
        },
      );

      if (response == null) {
        throw ChargilyException(
            'Failed to create checkout: No response from database',);
      }

      final data = response as Map<String, dynamic>;

      // Validate response has required fields
      if (!data.containsKey('checkout_url') ||
          !data.containsKey('checkout_id')) {
        throw ChargilyException(
            'Invalid response from database: Missing checkout_url or checkout_id',);
      }

      return ChargilyCheckoutResponse(
        checkoutUrl: data['checkout_url'] as String,
        checkoutId: data['checkout_id'] as String,
      );
    } on PostgrestException catch (e) {
      throw ChargilyException('Database error: ${e.message}');
    } catch (e) {
      throw ChargilyException('Error creating checkout: $e');
    }
  }
}

/// Response from Chargily checkout creation
class ChargilyCheckoutResponse {
  final String checkoutUrl;
  final String checkoutId;

  ChargilyCheckoutResponse({
    required this.checkoutUrl,
    required this.checkoutId,
  });
}

/// Exception thrown when Chargily operations fail
class ChargilyException implements Exception {
  final String message;

  ChargilyException(this.message);

  @override
  String toString() => 'ChargilyException: $message';
}

/// Provider for ChargilyRepository
@riverpod
ChargilyRepository chargilyRepository(ChargilyRepositoryRef ref) {
  final supabase = Supabase.instance.client;
  return ChargilyRepository(supabase);
}
