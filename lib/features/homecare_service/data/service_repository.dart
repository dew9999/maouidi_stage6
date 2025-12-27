// lib/features/homecare_service/data/service_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for homecare service tracking operations
class ServiceRepository {
  final SupabaseClient _supabase;

  ServiceRepository(this._supabase);

  /// Partner marks service as started (arrived at patient location)
  Future<void> markServiceStarted({
    required String requestId,
  }) async {
    await _supabase.from('homecare_requests').update({
      'service_started_at': DateTime.now().toIso8601String(),
      'status': 'in_progress',
    }).eq('id', requestId);
  }

  /// Partner marks service as completed
  Future<void> markServiceCompleted({
    required String requestId,
  }) async {
    await _supabase.from('homecare_requests').update({
      'service_completed_at': DateTime.now().toIso8601String(),
      'status': 'service_completed',
    }).eq('id', requestId);
  }

  /// Patient confirms service was received
  Future<void> confirmServiceReceived({
    required String requestId,
  }) async {
    await _supabase.from('homecare_requests').update({
      'patient_confirmed_at': DateTime.now().toIso8601String(),
      'status': 'completed',
    }).eq('id', requestId);
  }

  /// Get service status for a request
  Future<Map<String, dynamic>> getServiceStatus({
    required String requestId,
  }) async {
    final request = await _supabase
        .from('homecare_requests')
        .select(
          'status, service_started_at, service_completed_at, patient_confirmed_at, payment_status',
        )
        .eq('id', requestId)
        .single();

    return request;
  }

  /// Auto-confirm services that have been completed for >24h
  /// This should be called by a cron job
  Future<void> autoConfirmExpiredServices() async {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    await _supabase
        .from('homecare_requests')
        .update({
          'patient_confirmed_at': DateTime.now().toIso8601String(),
          'status': 'completed',
        })
        .eq('status', 'service_completed')
        .lt('service_completed_at', cutoffTime.toIso8601String());
  }

  /// Cancel service before it starts (refund scenarios)
  Future<void> cancelService({
    required String requestId,
    required String cancelledBy, // 'patient' or 'partner'
    required String reason,
  }) async {
    final status = cancelledBy == 'patient'
        ? 'cancelled_by_patient'
        : 'cancelled_by_partner';

    await _supabase.from('homecare_requests').update({
      'status': status,
      'cancellation_reason': reason,
    }).eq('id', requestId);
  }
}
