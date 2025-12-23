// lib/features/appointments/presentation/partner_dashboard_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/appointment_repository.dart';
import '../data/appointment_model.dart';
import 'partner_dashboard_state.dart';

part 'partner_dashboard_controller.g.dart';

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
/// Uses AsyncNotifier to handle asynchronous state updates.
@riverpod
class PartnerDashboardController extends _$PartnerDashboardController {
  late String _partnerId;

  @override
  Future<PartnerDashboardState> build(String partnerId) async {
    _partnerId = partnerId;
    // Load initial dashboard data
    return await loadDashboardData();
  }

  /// Loads all dashboard data (appointments, stats, today's appointments).
  Future<PartnerDashboardState> loadDashboardData() async {
    final repository = ref.read(appointmentRepositoryProvider);

    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        repository.getPartnerDashboardAppointments(_partnerId),
        repository.fetchTodayAppointments(_partnerId),
        repository.fetchDashboardStats(_partnerId),
      ]);

      final allAppointments = results[0] as List<AppointmentModel>;
      final todayAppointments = results[1] as List<AppointmentModel>;
      final stats = results[2] as Map<String, int>;

      // Find current patient (first confirmed appointment for queue-based)
      final currentPatient = todayAppointments.firstWhere(
        (appt) => appt.status == 'Confirmed',
        orElse: () =>
            todayAppointments.firstOrNull ??
            AppointmentModel(
              id: 0,
              partnerId: '',
              bookingUserId: '',
              appointmentTime: DateTime.now(),
              status: '',
            ),
      );

      return PartnerDashboardState(
        appointments: allAppointments,
        todayAppointments: todayAppointments,
        stats: stats,
        currentPatient: currentPatient.id == 0 ? null : currentPatient,
        isLoading: false,
      );
    } catch (e) {
      return PartnerDashboardState(
        errorMessage: 'Failed to load dashboard: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  /// Calls the next patient in the queue.
  ///
  /// Marks the next pending appointment as 'Confirmed' (Now Serving).
  Future<void> nextPatient() async {
    final repository = ref.read(appointmentRepositoryProvider);
    final currentState = await future;

    try {
      // Find the next pending appointment
      final nextAppt = currentState.todayAppointments.firstWhere(
        (appt) => appt.status == 'Pending',
        orElse: () => throw Exception('No pending appointments in queue'),
      );

      // Call the patient (mark as Confirmed)
      await repository.callPatient(nextAppt.id);

      // Reload dashboard data to get updated state
      state = AsyncValue.data(await loadDashboardData());
    } catch (e) {
      final updatedState = currentState.copyWith(
        errorMessage: 'Failed to call next patient: ${e.toString()}',
      );
      state = AsyncValue.data(updatedState);
    }
  }

  /// Cancels an appointment with a reason.
  ///
  /// Updates the appointment status to 'Cancelled_ByPartner'.
  Future<void> cancelAppointment(int id, String reason) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final currentState = await future;

    try {
      // Use the cancel and reorder queue RPC for queue-based systems
      await repository.cancelAndReorderQueue(id);

      // Reload dashboard data
      state = AsyncValue.data(await loadDashboardData());
    } catch (e) {
      final updatedState = currentState.copyWith(
        errorMessage: 'Failed to cancel appointment: ${e.toString()}',
      );
      state = AsyncValue.data(updatedState);
      rethrow;
    }
  }

  /// Marks an appointment as a no-show.
  Future<void> noShow(int id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final currentState = await future;

    try {
      await repository.updateAppointmentStatus(id, 'NoShow');

      // Reload dashboard data
      state = AsyncValue.data(await loadDashboardData());
    } catch (e) {
      final updatedState = currentState.copyWith(
        errorMessage: 'Failed to mark as no-show: ${e.toString()}',
      );
      state = AsyncValue.data(updatedState);
      rethrow;
    }
  }

  /// Marks an appointment as completed.
  Future<void> completeAppointment(int appointmentId) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final currentState = await future;

    try {
      await repository.markAsCompleted(appointmentId);

      // Reload dashboard data
      state = AsyncValue.data(await loadDashboardData());
    } catch (e) {
      final updatedState = currentState.copyWith(
        errorMessage: 'Failed to complete appointment: ${e.toString()}',
      );
      state = AsyncValue.data(updatedState);
      rethrow;
    }
  }

  /// Calls a specific patient (updates status to Confirmed).
  Future<void> callPatient(int id) async {
    final repository = ref.read(appointmentRepositoryProvider);
    final currentState = await future;

    try {
      await repository.callPatient(id);

      // Reload dashboard data
      state = AsyncValue.data(await loadDashboardData());
    } catch (e) {
      final updatedState = currentState.copyWith(
        errorMessage: 'Failed to call patient: ${e.toString()}',
      );
      state = AsyncValue.data(updatedState);
      rethrow;
    }
  }

  /// Confirms an appointment (alias for callPatient for clarity).
  Future<void> confirmAppointment(int id) async {
    await callPatient(id);
  }

  /// Updates the selected view filter.
  void setSelectedView(String view) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedView: view));
    });
  }

  /// Updates the selected status filter.
  void setSelectedStatus(String status) {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(selectedStatus: status));
    });
  }

  /// Clears any error messages.
  void clearError() {
    state.whenData((currentState) {
      state = AsyncValue.data(currentState.copyWith(errorMessage: null));
    });
  }

  /// Refreshes all dashboard data.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await loadDashboardData());
  }
}
