// lib/features/appointments/data/appointment_repository.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import 'appointment_model.dart';

part 'appointment_repository.g.dart';

/// Repository for appointment-related operations (Database 2.0).
///
/// Now uses unified `appointments` table for ALL booking types.
@riverpod
AppointmentRepository appointmentRepository(AppointmentRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AppointmentRepository(supabase);
}

class AppointmentRepository {
  AppointmentRepository(this._supabase);

  final SupabaseClient _supabase;

  // Simple caching mechanism
  List<AppointmentModel>? _cachedPartnerAppointments;
  String? _cachedPartnerId;
  DateTime? _cacheTimestamp;
  static const _cacheDuration = Duration(seconds: 5);

  /// Fetches all appointments for a specific partner (unified query).
  ///
  /// Includes clinic, homecare, and online bookings from single table.
  /// Uses a 5-second cache to reduce unnecessary database queries.
  Future<List<AppointmentModel>> getPartnerDashboardAppointments(
    String partnerId,
  ) async {
    // Check cache validity
    final now = DateTime.now();
    if (_cachedPartnerAppointments != null &&
        _cachedPartnerId == partnerId &&
        _cacheTimestamp != null &&
        now.difference(_cacheTimestamp!) < _cacheDuration) {
      print('Debug: Returning cached appointments for partner $partnerId');
      return _cachedPartnerAppointments!;
    }

    try {
      final response = await _supabase.rpc(
        'get_partner_dashboard_appointments',
        params: {'partner_id_arg': partnerId},
      );

      print('Debug: RPC response for partner $partnerId: $response');

      final appointments = (response as List)
          .map(
            (data) => AppointmentModel.fromSupabase(
              data as Map<String, dynamic>,
            ),
          )
          .toList();

      // Update cache
      _cachedPartnerAppointments = appointments;
      _cachedPartnerId = partnerId;
      _cacheTimestamp = now;

      return appointments;
    } catch (e) {
      print('Debug: Error fetching partner appointments: $e');
      throw AppointmentException('Failed to fetch appointments: $e');
    }
  }

  /// Invalidates the cache for partner appointments.
  /// Call this after any mutation to ensure fresh data on next fetch.
  void invalidatePartnerCache() {
    _cachedPartnerAppointments = null;
    _cachedPartnerId = null;
    _cacheTimestamp = null;
  }

  /// Fetches today's appointments for a specific partner.
  ///
  /// Filters appointments to only return those scheduled for today.
  Future<List<AppointmentModel>> fetchTodayAppointments(
    String partnerId,
  ) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final allAppointments = await getPartnerDashboardAppointments(partnerId);

      // Filter to today's appointments only
      final todayAppointments = allAppointments.where((appt) {
        final apptTime = appt.appointmentTime.toLocal();
        return apptTime.isAfter(startOfDay) && apptTime.isBefore(endOfDay);
      }).toList();

      // Sort by appointment number (for queue-based) or time
      todayAppointments.sort((AppointmentModel a, AppointmentModel b) {
        if (a.appointmentNumber != null && b.appointmentNumber != null) {
          return a.appointmentNumber!.compareTo(b.appointmentNumber!);
        }
        return a.appointmentTime.compareTo(b.appointmentTime);
      });

      return todayAppointments;
    } catch (e) {
      throw AppointmentException('Failed to fetch today appointments: $e');
    }
  }

  /// Fetches dashboard statistics for a specific partner.
  ///
  /// Returns counts for different appointment statuses.
  Future<Map<String, int>> fetchDashboardStats(String partnerId) async {
    try {
      final appointments = await getPartnerDashboardAppointments(partnerId);

      final stats = {
        'total': appointments.length,
        'pending': appointments.where((a) => a.status == 'Pending').length,
        'confirmed': appointments.where((a) => a.status == 'Confirmed').length,
        'completed': appointments.where((a) => a.status == 'Completed').length,
        'canceled': appointments
            .where(
              (a) =>
                  a.status == 'Cancelled_ByUser' ||
                  a.status == 'Cancelled_ByPartner' ||
                  a.status == 'NoShow',
            )
            .length,
      };

      return stats;
    } catch (e) {
      throw AppointmentException('Failed to fetch dashboard stats: $e');
    }
  }

  /// Creates a new appointment (unified for all types).
  ///
  /// Use `bookingType` parameter to specify: 'clinic', 'homecare', or 'online'.
  Future<void> createAppointment({
    required String partnerId,
    required DateTime appointmentTime,
    required String bookingType, // 'clinic', 'homecare', 'online'
    String? onBehalfOfName,
    String? onBehalfOfPhone,
    String? caseDescription,
    String? homecareAddress,
    bool isPartnerOverride = false,
  }) async {
    try {
      final appointmentData = <String, dynamic>{
        'partner_id': partnerId,
        'appointment_time': appointmentTime.toUtc().toIso8601String(),
        'booking_type': bookingType,
        'on_behalf_of_patient_name': onBehalfOfName,
        'on_behalf_of_patient_phone': onBehalfOfPhone,
        'case_description': caseDescription,
        'homecare_address': homecareAddress,
      };

      // Use the book_appointment RPC (it should handle the new fields)
      await _supabase.rpc(
        'book_appointment',
        params: {
          'partner_id_arg': partnerId,
          'appointment_time_arg': appointmentTime.toUtc().toIso8601String(),
          'on_behalf_of_name_arg': onBehalfOfName,
          'on_behalf_of_phone_arg': onBehalfOfPhone,
          'is_partner_override': isPartnerOverride,
          'case_description_arg': caseDescription,
          'patient_location_arg': homecareAddress,
        },
      );
    } catch (e) {
      throw AppointmentException('Failed to create appointment: $e');
    }
  }

  /// Updates the status of an appointment.
  ///
  /// Generic method to update appointment status to any valid value.
  Future<void> updateAppointmentStatus(int id, String status) async {
    try {
      final updateData = <String, dynamic>{'status': status};

      // If marking as completed, set completed_at timestamp
      if (status == 'Completed') {
        updateData['completed_at'] = DateTime.now().toUtc().toIso8601String();
      }

      await _supabase.from('appointments').update(updateData).eq('id', id);
    } catch (e) {
      throw AppointmentException('Failed to update appointment status: $e');
    }
  }

  /// Calls the next patient by updating their status to 'In Progress'.
  ///
  /// This triggers the "Now Serving" notification logic for queue-based systems.
  Future<void> callPatient(int id) async {
    try {
      await _supabase.from('appointments').update({
        'status': 'In Progress',
      }).eq('id', id);
    } catch (e) {
      throw AppointmentException('Failed to call patient: $e');
    }
  }

  /// Calls the next patient in the queue for a partner.
  ///
  /// Finds the next pending/confirmed appointment, completes any previous
  /// 'In Progress' appointment, and updates the next one to 'In Progress'.
  /// Returns the ID of the called patient or null if no pending appointments.
  Future<int?> callNextPatient(String partnerId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get all today's appointments for this partner
      final response = await _supabase
          .from('appointments')
          .select()
          .eq('partner_id', partnerId)
          .gte('appointment_time', startOfDay.toUtc().toIso8601String())
          .lt('appointment_time', endOfDay.toUtc().toIso8601String())
          .order('appointment_number', ascending: true);

      final appointments = (response as List)
          .map(
            (data) =>
                AppointmentModel.fromSupabase(data as Map<String, dynamic>),
          )
          .toList();

      // Complete any existing 'In Progress' appointment
      final inProgressAppt = appointments.firstWhere(
        (appt) => appt.status == 'In Progress',
        orElse: () => AppointmentModel(
          id: 0,
          partnerId: '',
          bookingUserId: '',
          appointmentTime: DateTime.now(),
          status: '',
        ),
      );

      if (inProgressAppt.id != 0) {
        await markAsCompleted(inProgressAppt.id);
      }

      // Find next pending or confirmed appointment
      final nextAppt = appointments.firstWhere(
        (appt) => appt.status == 'Pending' || appt.status == 'Confirmed',
        orElse: () => AppointmentModel(
          id: 0,
          partnerId: '',
          bookingUserId: '',
          appointmentTime: DateTime.now(),
          status: '',
        ),
      );

      if (nextAppt.id == 0) {
        return null; // No pending appointments
      }

      // Update next appointment to 'In Progress'
      await callPatient(nextAppt.id);
      return nextAppt.id;
    } catch (e) {
      throw AppointmentException('Failed to call next patient: $e');
    }
  }

  /// Pushes a patient to the back of the queue.
  ///
  /// Updates the appointment's queue_number to max + 1 and status to Pending.
  /// Used when the current "Now Serving" patient needs to be repositioned.
  Future<void> pushPatientToBack(int appointmentId, String partnerId) async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      // Get today's appointments to find max queue number
      final response = await _supabase
          .from('appointments')
          .select('appointment_number')
          .eq('partner_id', partnerId)
          .gte('appointment_time', startOfDay.toUtc().toIso8601String())
          .lt('appointment_time', endOfDay.toUtc().toIso8601String())
          .not('appointment_number', 'is', null);

      final appointments = response as List;
      final queueNumbers = appointments
          .map((a) => a['appointment_number'] as int?)
          .whereType<int>()
          .toList();

      final maxQueueNumber = queueNumbers.isEmpty
          ? 0
          : queueNumbers.reduce((a, b) => a > b ? a : b);

      // Update appointment to back of queue with Pending status
      await _supabase.from('appointments').update({
        'appointment_number': maxQueueNumber + 1,
        'status': 'Pending',
      }).eq('id', appointmentId);
    } catch (e) {
      throw AppointmentException('Failed to push patient to back: $e');
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

  /// Fetches appointments for a specific patient (user).
  ///
  /// Filters by booking_user_id and status, with optional time-based filtering.
  /// Includes partner details via join.
  Future<List<Map<String, dynamic>>> fetchPatientAppointments(
    String userId,
    List<String> statuses, {
    bool? isUpcoming,
  }) async {
    try {
      var query = _supabase
          .from('appointments')
          .select(
            '*, appointment_number, has_review, completed_at, medical_partners(full_name, specialty, category)',
          )
          .eq('booking_user_id', userId)
          .inFilter('status', statuses);

      if (isUpcoming != null) {
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        final filterTime = startOfToday.toUtc().toIso8601String();

        if (isUpcoming) {
          query = query.gte('appointment_time', filterTime);
        } else {
          query = query.lt('appointment_time', now.toUtc().toIso8601String());
        }
      }

      final response =
          await query.order('appointment_time', ascending: isUpcoming ?? false);

      print(
          'Debug: Patient appointments for $userId (Status: $statuses, Upcoming: $isUpcoming): ${response.length} found');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Debug: Error fetching patient appointments: $e');
      throw AppointmentException('Failed to fetch patient appointments: $e');
    }
  }

  /// Watches appointments for a specific patient using Supabase Realtime.
  ///
  /// Returns a stream that emits updated appointment lists whenever
  /// the appointments table changes for this patient.
  Stream<List<Map<String, dynamic>>> watchPatientAppointments(
    String userId,
    List<String> statuses, {
    bool? isUpcoming,
  }) async* {
    // First, yield the initial data
    final initialData = await fetchPatientAppointments(
      userId,
      statuses,
      isUpcoming: isUpcoming,
    );
    yield initialData;

    // Create a StreamController to emit updates
    final controller = StreamController<List<Map<String, dynamic>>>();

    // Set up realtime subscription with proper callback
    final channel = _supabase.channel('patient_appointments_$userId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'booking_user_id',
            value: userId,
          ),
          callback: (payload) async {
            // Re-fetch data when changes occur
            try {
              final updatedData = await fetchPatientAppointments(
                userId,
                statuses,
                isUpcoming: isUpcoming,
              );
              if (!controller.isClosed) {
                controller.add(updatedData);
              }
            } catch (e) {
              print('Error fetching updated patient appointments: $e');
              // Don't add error to stream, just log it
            }
          },
        )
        .subscribe();

    // Yield updates from the controller
    await for (final data in controller.stream) {
      yield data;
    }

    // Cleanup: unsubscribe when stream is cancelled
    await channel.unsubscribe();
    await controller.close();
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

    // Create a StreamController to emit updates
    final controller = StreamController<List<AppointmentModel>>();

    // Set up realtime subscription with proper callback
    final channel = _supabase.channel('appointments_$partnerId');

    channel
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'appointments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'partner_id',
            value: partnerId,
          ),
          callback: (payload) async {
            // When any change occurs, re-fetch all appointments
            // This ensures consistency with the RPC function logic
            try {
              final updatedData =
                  await getPartnerDashboardAppointments(partnerId);
              if (!controller.isClosed) {
                controller.add(updatedData);
              }
            } catch (e) {
              print('Error fetching updated partner appointments: $e');
              // Don't add error to stream, just log it
            }
          },
        )
        .subscribe();

    // Yield updates from the controller
    await for (final data in controller.stream) {
      yield data;
    }

    // Cleanup: unsubscribe when stream is cancelled
    await channel.unsubscribe();
    await controller.close();
  }
}

/// Custom exception for appointment-related errors.
class AppointmentException implements Exception {
  AppointmentException(this.message);

  final String message;

  @override
  String toString() => 'AppointmentException: $message';
}
