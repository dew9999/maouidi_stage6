// lib/features/payments/data/refund_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'chargily_service.dart';

/// Service for handling refunds
class RefundService {
  final SupabaseClient _supabase;
  final ChargilyService _chargilyService;

  RefundService(this._supabase, this._chargilyService);

  /// Process refund for a homecare request via Edge Function
  ///
  /// The Edge Function validates eligibility and processes the refund securely
  Future<Map<String, dynamic>> processRefund({
    required String requestId,
    required String cancelledBy, // 'patient' or 'partner'
    required String reason,
  }) async {
    // Call Edge Function to process refund
    // It will:
    // 1. Validate refund eligibility (100%/50%/0%)
    // 2. Process refund via Chargily API
    // 3. Update database
    final result = await _chargilyService.processRefund(
      requestId: requestId,
      cancelledBy: cancelledBy,
      cancellationReason: reason,
    );

    // Check if refund was eligible
    if (result['eligible'] == false) {
      throw Exception(result['reason'] ?? 'Refund not eligible');
    }

    return result;
  }

  /// Get refund details for a request
  Future<Map<String, dynamic>?> getRefundDetails(String requestId) async {
    final request = await _supabase
        .from('appointments')
        .select(
          'refund_status, refund_amount, refunded_at, cancellation_reason',
        )
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
        .single();

    if (request['refund_status'] == null) {
      return null;
    }

    return request;
  }

  /// Calculate potential refund amount (preview before cancelling)
  Future<Map<String, dynamic>> calculateRefundAmount({
    required String requestId,
    required String cancelledBy,
  }) async {
    final request = await _supabase
        .from('appointments')
        .select('total_amount, started_at, payment_status')
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
        .single();

    final totalAmount = (request['total_amount'] as num?)?.toDouble() ?? 0;
    final serviceStartedAt = request['started_at'] as String?;
    final paymentStatus = request['payment_status'] as String;

    if (paymentStatus != 'paid') {
      return {
        'refundable': false,
        'refund_amount': 0,
        'reason': 'Payment not completed',
      };
    }

    if (cancelledBy == 'partner' && serviceStartedAt == null) {
      return {
        'refundable': true,
        'refund_amount': totalAmount,
        'refund_percentage': 100,
        'reason': 'Partner cancellation - Full refund',
      };
    } else if (cancelledBy == 'patient' && serviceStartedAt == null) {
      return {
        'refundable': true,
        'refund_amount': totalAmount * 0.5,
        'refund_percentage': 50,
        'reason': 'Patient cancellation before service - 50% refund',
      };
    } else if (serviceStartedAt != null) {
      return {
        'refundable': false,
        'refund_amount': 0,
        'refund_percentage': 0,
        'reason': 'Service already started - No refund available',
      };
    }

    return {
      'refundable': false,
      'refund_amount': 0,
      'reason': 'Invalid scenario',
    };
  }
}
