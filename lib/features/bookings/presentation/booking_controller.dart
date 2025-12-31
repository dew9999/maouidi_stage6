// lib/features/bookings/presentation/booking_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/booking_repository.dart';
import '../../payment/data/chargily_repository.dart';
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

  /// Confirm and book the appointment (unified for all booking types).
  ///
  /// Uses the unified appointments table for both clinic and homecare bookings.
  /// - Clinic appointments: bookingType = 'clinic' → Book immediately
  /// - Homecare requests: bookingType = 'homecare' → Payment flow → Then book
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
      final partnerData = state.partnerData;

      // Check if this is a homecare request that requires payment
      // STRICTLY limit payment to 'Homecare' category only. All others are free.
      final isHomecareRequest = partnerData?.category == 'Homecare';

      if (isHomecareRequest) {
        print(
            '💰 HOMECARE FLOW: Initiating payment for partner ${partnerData?.fullName}',);
        // HOMECARE FLOW: Payment Required
        // Step 1: Create Chargily checkout session
        final chargilyRepo = ref.read(chargilyRepositoryProvider);
        final userId = Supabase.instance.client.auth.currentUser?.id;

        if (userId == null) {
          throw Exception('User not authenticated');
        }

        final checkoutResponse = await chargilyRepo.createCheckoutSession(
          amount: partnerData?.homecarePrice ?? 2000.0,
          currency: 'DZD',
          userId: userId,
          partnerId: partnerId,
          appointmentTime: appointmentTime.toIso8601String(),
        );

        // Check if we're in test mode (checkout URL contains '/test/')
        final isTestMode = checkoutResponse.checkoutUrl.contains('/test/');

        if (isTestMode) {
          // TEST MODE: Create appointment immediately without waiting for payment
          // This allows testing the full homecare flow end-to-end
          await repository.bookAppointment(
            partnerId: partnerId,
            appointmentTime: appointmentTime,
            onBehalfOfName: onBehalfOfName,
            onBehalfOfPhone: onBehalfOfPhone,
            isPartnerOverride: isPartnerOverride,
            caseDescription: caseDescription,
            patientLocation: patientLocation,
            // Mark as pending payment in test mode
            paymentStatus: 'pending',
            paymentTransactionId: checkoutResponse.checkoutId,
            amountPaid: partnerData?.homecarePrice ?? 2000.0,
          );

          // Success - appointment created in test mode
          state = state.copyWith(
            bookingStatus: BookingStatus.success,
            errorMessage: null,
          );

          print('✅ TEST MODE: Homecare appointment created immediately');
        } else {
          // PRODUCTION MODE: Redirect to payment
          // Step 2: Launch browser with checkout URL
          final url = Uri.parse(checkoutResponse.checkoutUrl);
          if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
            throw Exception('Could not launch payment URL');
          }

          // Step 3: Mark state as redirecting
          state = state.copyWith(
            bookingStatus: BookingStatus.redirecting,
          );

          // NOTE: The actual booking will happen when the user returns from payment
          // and triggers the webhook handler
          print('🔄 PRODUCTION MODE: Redirecting to payment gateway');
        }
      } else {
        print(
            '🏥 CLINIC/ONLINE FLOW: Free booking for partner ${partnerData?.fullName} (Category: ${partnerData?.category})',);
        // CLINIC/ONLINE FLOW: Book immediately (FREE)
        await repository.bookAppointment(
          partnerId: partnerId,
          appointmentTime: appointmentTime,
          onBehalfOfName: onBehalfOfName,
          onBehalfOfPhone: onBehalfOfPhone,
          isPartnerOverride: isPartnerOverride,
          caseDescription: caseDescription,
          patientLocation: patientLocation,
          // No payment arguments for clinic/online - defaults to free/unpaid in repository
        );

        // Success
        state = state.copyWith(
          bookingStatus: BookingStatus.success,
          errorMessage: null,
        );
      }
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
