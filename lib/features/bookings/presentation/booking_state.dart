// lib/features/bookings/presentation/booking_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/booking_repository.dart';

part 'booking_state.freezed.dart';

/// Booking status enum
enum BookingStatus {
  initial,
  loading,
  redirecting, // NEW: For payment redirect
  success,
  error,
}

/// State for the booking flow.
///
/// Manages selected date, available slots, partner data, and booking status.
@freezed
class BookingState with _$BookingState {
  const factory BookingState({
    required DateTime selectedDate,
    String? selectedSlot,
    @Default([]) List<TimeSlot> availableSlots,
    PartnerBookingData? partnerData,
    @Default(false) bool isLoadingSlots,
    @Default(false) bool isLoadingPartner,
    @Default(BookingStatus.initial) BookingStatus bookingStatus,
    String? errorMessage,
  }) = _BookingState;

  factory BookingState.initial() => BookingState(
        selectedDate: DateTime.now(),
      );
}
