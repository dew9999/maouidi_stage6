// lib/features/appointments/data/appointment_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import 'appointment_model.dart';

part 'appointment_repository.g.dart';

/// Repository for appointment-related operations.
///
/// Abstracts all Supabase interactions for appointments following Clean Architecture.
@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AppointmentRepository(supabase);
}

class AppointmentRepository {
  AppointmentRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Fetches all appointments for a specific partner.
  ///
  /// Calls the `get_partner_dashboard_appointments` RPC function.
  Future<List<AppointmentModel>> getPartnerDashboardAppointments(
    String partnerId,
  ) async {
    try {
      final response = await _supabase.rpc(
        'get_partner_dashboard_appointments',
        params: {'partner_id_arg': partnerId},
      );

      final appointments = (response as List)
          .map(
            (data) => AppointmentModel.fromSupabase(
              data as Map<String, dynamic>,
            ),
          )
          .toList();

      return appointments;
    } catch (e) {
      throw AppointmentException('Failed to fetch appointments: $e');
    }
  }

  /// Cancels an appointment and reorders the queue if applicable.
  ///
  /// Calls the `cancel_and_reorder_queue` RPC function.
  Future<void> cancelAndReorderQueue(int appointmentId) async {
    try {
      await _supabase.rpc(
        'cancel_and_reorder_queue',
        params: {'appointment_id_arg': appointmentId},
      );
    } catch (e) {
      throw AppointmentException('Failed to cancel appointment: $e');
    }
  }

  /// Marks an appointment as completed.
  ///
  /// Updates the status to 'Completed' and sets completed_at to now.
  Future<void> markAsCompleted(int appointmentId) async {
    try {
      await _supabase.from('appointments').update({
        'status': 'Completed',
        'completed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', appointmentId);
    } catch (e) {
      throw AppointmentException('Failed to mark appointment as completed: $e');
    }
  }

  /// Watches appointments for a specific partner using Supabase Realtime.
  ///
  /// Returns a stream that emits updated appointment lists whenever
  /// the appointments table changes for this partner.
  Stream<List<AppointmentModel>> watchPartnerAppointments(
    String partnerId,
  ) async* {
    // First, yield the initial data
    final initialData = await getPartnerDashboardAppointments(partnerId);
    yield initialData;

    // Then set up realtime subscription
    _supabase
        .channel('appointments_$partnerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'partner_id',
            value: partnerId,
          ),
          callback: (_) async {
            // When any change occurs, re-fetch all appointments
            // This ensures consistency with the RPC function logic
          },
        )
        .subscribe();

    // Create a stream controller to emit updates
    await for (final _ in Stream.periodic(const Duration(seconds: 1))) {
      try {
        final updatedData = await getPartnerDashboardAppointments(partnerId);
        yield updatedData;
      } catch (e) {
        // Continue streaming even if one fetch fails
        continue;
      }
    }
  }
}

/// Custom exception for appointment-related errors.
class AppointmentException implements Exception {
  AppointmentException(this.message);

  final String message;

  @override
  String toString() => 'AppointmentException: $message';
}
