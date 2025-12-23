// lib/features/bookings/data/booking_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';

part 'booking_repository.g.dart';

/// Repository for booking-related database operations.
///
/// Provides clean interface for appointment booking.
class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository(this._supabase);

  /// Book an appointment with a medical partner.
  ///
  /// Calls the `book_appointment` RPC function from schema.sql.
  /// This function handles all booking validation and slot allocation.
  ///
  /// Throws [PostgrestException] if booking fails (e.g., slot taken, partner closed).
  Future<void> bookAppointment({
    required String partnerId,
    required DateTime appointmentTime,
    String? onBehalfOfName,
    String? onBehalfOfPhone,
    required bool isPartnerOverride,
    String? caseDescription,
    String? patientLocation,
  }) async {
    await _supabase.rpc(
      'book_appointment',
      params: {
        'partner_id_arg': partnerId,
        'appointment_time_arg': appointmentTime.toIso8601String(),
        'on_behalf_of_name_arg': onBehalfOfName,
        'on_behalf_of_phone_arg': onBehalfOfPhone,
        'is_partner_override': isPartnerOverride,
        'case_description_arg': caseDescription,
        'patient_location_arg': patientLocation,
      },
    );
  }
}

/// Provider for the BookingRepository.
@riverpod
BookingRepository bookingRepository(BookingRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return BookingRepository(supabase);
}
