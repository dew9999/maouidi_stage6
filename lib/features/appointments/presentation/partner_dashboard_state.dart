// lib/features/appointments/presentation/partner_dashboard_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../data/appointment_model.dart';

part 'partner_dashboard_state.freezed.dart';

/// State for the Partner Dashboard.
///
/// Contains the list of appointments and UI filter states.
@freezed
class PartnerDashboardState with _$PartnerDashboardState {
  const factory PartnerDashboardState({
    required List<AppointmentModel> appointments,
    @Default('schedule') String selectedView,
    @Default('Pending') String selectedStatus,
    String? errorMessage,
  }) = _PartnerDashboardState;

  factory PartnerDashboardState.initial() =>
      const PartnerDashboardState(appointments: []);
}
