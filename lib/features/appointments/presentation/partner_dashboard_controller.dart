// lib/features/appointments/presentation/partner_dashboard_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/appointment_repository.dart';
import 'partner_dashboard_state.dart';
import 'appointments_stream_provider.dart';

part 'partner_dashboard_controller.g.dart';

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
@riverpod
class PartnerDashboardController extends _$PartnerDashboardController {
  @override
  PartnerDashboardState build(String partnerId) {
    // Watch the appointments stream and update state automatically
    final appointmentsAsync = ref.watch(appointmentsStreamProvider(partnerId));

    return appointmentsAsync.when(
      data: (appointments) => PartnerDashboardState(appointments: appointments),
      loading: () => PartnerDashboardState.initial(),
      error: (error, _) => PartnerDashboardState(
        appointments: [],
        errorMessage: error.toString(),
      ),
    );
  }

  /// Cancels an appointment and reorders the queue if applicable.
  Future<void> cancelAppointment(int appointmentId) async {
    final repository = ref.read(appointmentRepositoryProvider);

    try {
      await repository.cancelAndReorderQueue(appointmentId);
      // Stream will auto-update the UI
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to cancel appointment: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Marks an appointment as completed.
  Future<void> completeAppointment(int appointmentId) async {
    final repository = ref.read(appointmentRepositoryProvider);

    try {
      await repository.markAsCompleted(appointmentId);
      // Stream will auto-update the UI
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to complete appointment: ${e.toString()}',
      );
      rethrow;
    }
  }

  /// Updates the selected view filter.
  void setSelectedView(String view) {
    state = state.copyWith(selectedView: view);
  }

  /// Updates the selected status filter.
  void setSelectedStatus(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  /// Clears any error messages.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
