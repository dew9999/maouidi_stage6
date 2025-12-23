// lib/features/appointments/presentation/partner_dashboard_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/appointment_model.dart';

part 'partner_dashboard_state.freezed.dart';

/// State for the Partner Dashboard.
///
/// Contains all appointment data, statistics, and UI filter states.
@freezed
class PartnerDashboardState with _$PartnerDashboardState {
  const factory PartnerDashboardState({
    /// All appointments for the partner
    @Default([]) List<AppointmentModel> appointments,

    /// Today's appointments (filtered by date)
    @Default([]) List<AppointmentModel> todayAppointments,

    /// Dashboard statistics (pending, completed, etc.)
    @Default({}) Map<String, int> stats,

    /// Current patient being served (for queue-based systems)
    AppointmentModel? currentPatient,

    /// Loading state
    @Default(false) bool isLoading,

    /// Current view selection ('schedule' or 'analytics')
    @Default('schedule') String selectedView,

    /// Current status filter ('Pending', 'Confirmed', 'Completed', 'Canceled')
    @Default('Pending') String selectedStatus,

    /// Error message if any operation fails
    String? errorMessage,
  }) = _PartnerDashboardState;

  /// Factory for initial state
  factory PartnerDashboardState.initial() => const PartnerDashboardState();

  /// Factory for loading state
  factory PartnerDashboardState.loading() => const PartnerDashboardState(
        isLoading: true,
      );
}
