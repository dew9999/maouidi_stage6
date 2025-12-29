// lib/features/homecare_service/data/service_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for homecare service tracking operations
class ServiceRepository {
  final SupabaseClient _supabase;

  ServiceRepository(this._supabase);

  /// Partner marks service as started (arrived at patient location)
  Future<void> markServiceStarted({
    required String appointmentId,
  }) async {
    await _supabase
        .from('appointments')
        .update({
          'started_at': DateTime.now().toIso8601String(),
          'status': 'in_progress',
        })
        .eq('id', appointmentId)
        .eq('booking_type', 'homecare');
  }

  /// Partner marks service as completed
  Future<void> markServiceCompleted({
    required String appointmentId,
  }) async {
    await _supabase
        .from('appointments')
        .update({
          'completed_at': DateTime.now().toIso8601String(),
          'status': 'completed',
        })
        .eq('id', appointmentId)
        .eq('booking_type', 'homecare');
  }

  /// Patient confirms service was received
  Future<void> confirmServiceReceived({
    required String appointmentId,
  }) async {
    await _supabase
        .from('appointments')
        .update({
          'patient_confirmed_at': DateTime.now().toIso8601String(),
          'status': 'completed',
        })
        .eq('id', appointmentId)
        .eq('booking_type', 'homecare');
  }

  /// Get service status for an appointment
  Future<Map<String, dynamic>> getServiceStatus({
    required String appointmentId,
  }) async {
    final appointment = await _supabase
        .from('appointments')
        .select(
          'status, started_at, completed_at, patient_confirmed_at, payment_status',
        )
        .eq('id', appointmentId)
        .eq('booking_type', 'homecare')
        .single();

    return appointment;
  }

  /// Auto-confirm services that have been completed for >24h
  /// This should be called by a cron job
  Future<void> autoConfirmExpiredServices() async {
    final cutoffTime = DateTime.now().subtract(const Duration(hours: 24));

    await _supabase
        .from('appointments')
        .update({
          'patient_confirmed_at': DateTime.now().toIso8601String(),
          'status': 'completed',
        })
        .eq('booking_type', 'homecare')
        .eq('status', 'completed')
        .lt('completed_at', cutoffTime.toIso8601String());
  }

  /// Cancel service before it starts (refund scenarios)
  Future<void> cancelService({
    required String appointmentId,
    required String cancelledBy, // 'patient' or 'partner'
    required String reason,
  }) async {
    await _supabase
        .from('appointments')
        .update({
          'status': 'cancelled',
          'cancellation_reason': reason,
          'cancelled_by': cancelledBy,
          'cancelled_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId)
        .eq('booking_type', 'homecare');
  }

  /// Accept homecare request and move to confirmed status
  Future<void> acceptRequest({
    required String appointmentId,
  }) async {
    await _supabase
        .from('appointments')
        .update({
          'status': 'confirmed',
          'confirmed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', appointmentId)
        .eq('booking_type', 'homecare');
  }
}
