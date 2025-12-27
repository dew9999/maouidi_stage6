// lib/features/payments/data/refund_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import 'chargily_service.dart';

/// Service for handling refunds
class RefundService {
  final SupabaseClient _supabase;
  final ChargilyService _chargilyService;

  RefundService(this._supabase, this._chargilyService);

  /// Process refund for a homecare request
  Future<void> processRefund({
    required String requestId,
    required String cancelledBy,
    required String reason,
  }) async {
    // Get request details
    final request = await _supabase
        .from('homecare_requests')
        .select(
            'payment_status, chargily_checkout_id, total_amount, service_started_at, status')
        .eq('id', requestId)
        .single();

    final paymentStatus = request['payment_status'] as String;
    final chargilyCheckoutId = request['chargily_checkout_id'] as String?;
    final totalAmount = (request['total_amount'] as num?)?.toDouble();
    final serviceStartedAt = request['service_started_at'] as String?;

    // Validate payment was made
    if (paymentStatus != 'paid' ||
        chargilyCheckoutId == null ||
        totalAmount == null) {
      throw Exception('No payment to refund');
    }

    // Determine refund amount based on scenario
    double refundAmount;
    String refundReason;

    if (cancelledBy == 'partner' && serviceStartedAt == null) {
      // Partner cancels before service → 100% refund
      refundAmount = totalAmount;
      refundReason = 'Partner cancelled - Full refund';
    } else if (cancelledBy == 'patient' && serviceStartedAt == null) {
      // Patient cancels before service → 50% refund
      refundAmount = totalAmount * 0.5;
      refundReason = 'Patient cancelled before service - 50% refund';
    } else if (cancelledBy == 'patient' && serviceStartedAt != null) {
      // Patient cancels after service started → NO REFUND
      throw Exception(
          'Cannot cancel after service has started. No refund available.');
    } else {
      throw Exception('Invalid refund scenario');
    }

    // Process refund via Chargily
    await _chargilyService.processRefund(
      checkoutId: chargilyCheckoutId,
      amount: refundAmount,
    );

    // Update request in database
    await _supabase.from('homecare_requests').update({
      'status': cancelledBy == 'partner'
          ? 'cancelled_by_partner'
          : 'cancelled_by_patient',
      'refund_status': 'completed',
      'refund_amount': refundAmount,
      'refunded_at': DateTime.now().toIso8601String(),
      'cancellation_reason': reason,
    }).eq('id', requestId);
  }

  /// Get refund details for a request
  Future<Map<String, dynamic>?> getRefundDetails(String requestId) async {
    final request = await _supabase
        .from('homecare_requests')
        .select(
            'refund_status, refund_amount, refunded_at, cancellation_reason')
        .eq('id', requestId)
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
        .from('homecare_requests')
        .select('total_amount, service_started_at, payment_status')
        .eq('id', requestId)
        .single();

    final totalAmount = (request['total_amount'] as num?)?.toDouble() ?? 0;
    final serviceStartedAt = request['service_started_at'] as String?;
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
