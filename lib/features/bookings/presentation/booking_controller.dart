// lib/features/bookings/presentation/booking_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/booking_repository.dart';
import 'booking_state.dart';

part 'booking_controller.g.dart';

/// Controller for managing the complete booking flow.
///
/// Manages UI state including date selection, slot availability, and booking confirmation.
@riverpod
class BookingController extends _$BookingController {
  @override
  BookingState build(String partnerId) {
    // Initialize state with current date
    final initialState = BookingState.initial();

    // Load partner data in the background
    Future.microtask(() => _loadPartnerData(partnerId));

    return initialState;
  }

  /// Load partner configuration data.
  Future<void> _loadPartnerData(String partnerId) async {
    state = state.copyWith(isLoadingPartner: true);

    try {
      final repository = ref.read(bookingRepositoryProvider);
      final partnerData = await repository.fetchPartnerData(partnerId);

      state = state.copyWith(
        partnerData: partnerData,
        isLoadingPartner: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingPartner: false,
        errorMessage: 'Failed to load partner data',
      );
    }
  }

  /// Handle date selection from calendar.
  ///
  /// Updates selected date and fetches available slots for time-based bookings.
  Future<void> onDateSelected(DateTime date, String partnerId) async {
    // Update selected date immediately
    state = state.copyWith(
      selectedDate: date,
      selectedSlot: null, // Clear selected slot
      isLoadingSlots: true,
    );

    // Fetch slots only for time-based bookings
    final partnerData = state.partnerData;
    if (partnerData?.bookingSystemType == 'time_based') {
      try {
        final repository = ref.read(bookingRepositoryProvider);
        final slots = await repository.fetchAvailableSlots(
          partnerId: partnerId,
          date: date,
        );

        state = state.copyWith(
          availableSlots: slots,
          isLoadingSlots: false,
        );
      } catch (e) {
        state = state.copyWith(
          availableSlots: [],
          isLoadingSlots: false,
          errorMessage: 'Failed to load time slots',
        );
      }
    } else {
      // For number-based, just clear loading state
      state = state.copyWith(isLoadingSlots: false);
    }
  }

  /// Handle slot selection (for time-based bookings).
  void onSlotSelected(String slot) {
    state = state.copyWith(selectedSlot: slot);
  }

  /// Confirm and book the appointment.
  ///
  /// Uses current state to determine booking parameters.
  Future<void> confirmBooking({
    required String partnerId,
    required DateTime appointmentTime,
    String? onBehalfOfName,
    String? onBehalfOfPhone,
    required bool isPartnerOverride,
    String? caseDescription,
    String? patientLocation,
  }) async {
    // Set booking status to loading
    state = state.copyWith(bookingStatus: BookingStatus.loading);

    try {
      final repository = ref.read(bookingRepositoryProvider);
      await repository.bookAppointment(
        partnerId: partnerId,
        appointmentTime: appointmentTime,
        onBehalfOfName: onBehalfOfName,
        onBehalfOfPhone: onBehalfOfPhone,
        isPartnerOverride: isPartnerOverride,
        caseDescription: caseDescription,
        patientLocation: patientLocation,
      );

      // Success
      state = state.copyWith(
        bookingStatus: BookingStatus.success,
        errorMessage: null,
      );
    } catch (e) {
      // Error
      state = state.copyWith(
        bookingStatus: BookingStatus.error,
        errorMessage: e.toString(),
      );
      // Re-throw so UI can handle it
      rethrow;
    }
  }

  /// Reset booking status after handling success/error.
  void resetBookingStatus() {
    state = state.copyWith(
      bookingStatus: BookingStatus.initial,
      errorMessage: null,
    );
  }
}
