// lib/features/bookings/presentation/booking_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/booking_repository.dart';

part 'booking_controller.g.dart';

/// Controller for managing booking operations.
///
/// Handles appointment booking with loading and error state management.
@riverpod
class BookingController extends _$BookingController {
  @override
  FutureOr<void> build() async {
    // Initial state is a completed future with no data
  }

  /// Book an appointment with the specified parameters.
  ///
  /// Updates state to loading during the operation, then success or error.
  /// Throws exceptions to be caught by the UI layer.
  Future<void> bookAppointment({
    required String partnerId,
    required DateTime appointmentTime,
    String? onBehalfOfName,
    String? onBehalfOfPhone,
    required bool isPartnerOverride,
    String? caseDescription,
    String? patientLocation,
  }) async {
    // Set state to loading
    state = const AsyncValue.loading();

    // Perform the booking operation
    state = await AsyncValue.guard(() async {
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
    });
  }
}
