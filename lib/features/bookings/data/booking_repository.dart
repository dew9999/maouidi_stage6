// lib/features/bookings/data/booking_repository.dart

import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';

part 'booking_repository.g.dart';

/// Status of a time slot
enum SlotStatus { available, booked, inPast }

/// Represents a time slot for booking
class TimeSlot {
  final DateTime time;
  final SlotStatus status;

  TimeSlot({required this.time, required this.status});
}

/// Partner data model for booking
class PartnerBookingData {
  final String bookingSystemType;
  final String fullName;
  final String? category;
  final List<DateTime> closedDays;
  final Map<String, dynamic> workingHours;

  PartnerBookingData({
    required this.bookingSystemType,
    required this.fullName,
    this.category,
    required this.closedDays,
    required this.workingHours,
  });

  factory PartnerBookingData.fromJson(Map<String, dynamic> json) {
    final closedDaysRaw = json['closed_days'] as List<dynamic>? ?? [];
    final closedDays =
        closedDaysRaw.map((day) => DateTime.parse(day.toString())).toList();

    return PartnerBookingData(
      bookingSystemType: json['booking_system_type'] as String? ?? 'time_based',
      fullName: json['full_name'] as String? ?? 'Unknown',
      category: json['category'] as String?,
      closedDays: closedDays,
      workingHours: json['working_hours'] as Map<String, dynamic>? ?? {},
    );
  }
}

/// Repository for booking-related database operations.
///
/// Provides clean interface for appointment booking.
class BookingRepository {
  final SupabaseClient _supabase;

  BookingRepository(this._supabase);

  /// Fetch available time slots for a partner on a specific date.
  ///
  /// Calls the `get_available_slots` RPC function.
  /// Returns a list of available TimeSlot objects.
  Future<List<TimeSlot>> fetchAvailableSlots({
    required String partnerId,
    required DateTime date,
  }) async {
    final String dayArg = DateFormat('yyyy-MM-dd').format(date);

    try {
      final response = await _supabase.rpc(
        'get_available_slots',
        params: {
          'partner_id_arg': partnerId,
          'day_arg': dayArg,
        },
      );

      final List<TimeSlot> availableSlots = (response as List<dynamic>)
          .map(
            (item) => TimeSlot(
              time: DateTime.parse(item['available_slot'] as String),
              status: SlotStatus.available,
            ),
          )
          .toList();

      return availableSlots;
    } catch (error) {
      // Return empty list on error - UI will handle displaying "no slots"
      return [];
    }
  }

  /// Fetch partner booking configuration data.
  ///
  /// Returns partner's booking system type, name, closed days, and working hours.
  Future<PartnerBookingData?> fetchPartnerData(String partnerId) async {
    try {
      final response = await _supabase
          .from('medical_partners')
          .select(
            'booking_system_type, full_name, closed_days, category, working_hours',
          )
          .eq('id', partnerId)
          .maybeSingle();

      if (response == null) return null;

      return PartnerBookingData.fromJson(response);
    } catch (error) {
      return null;
    }
  }

  /// Book an appointment with a medical partner.
  ///
  /// Calls the `book_appointment` RPC function from schema.sql.
  /// This function handles all booking validation and slot allocation.
  ///
  /// For homecare bookings with payment, pass payment_status, transaction_id, and amount_paid.
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
    // NEW: Payment arguments (optional, default to unpaid)
    String? paymentStatus,
    String? paymentTransactionId,
    double? amountPaid,
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
        // NEW: Payment arguments
        if (paymentStatus != null) 'payment_status_arg': paymentStatus,
        if (paymentTransactionId != null)
          'payment_transaction_id_arg': paymentTransactionId,
        if (amountPaid != null) 'amount_paid_arg': amountPaid,
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
