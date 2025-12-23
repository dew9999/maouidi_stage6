// lib/features/patient/presentation/patient_dashboard_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_dashboard_state.freezed.dart';

/// State for the Patient Dashboard.
///
/// Manages upcoming, completed, and canceled appointments.
@freezed
class PatientDashboardState with _$PatientDashboardState {
  const factory PatientDashboardState({
    @Default([]) List<Map<String, dynamic>> upcomingAppointments,
    @Default([]) List<Map<String, dynamic>> completedAppointments,
    @Default([]) List<Map<String, dynamic>> canceledAppointments,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PatientDashboardState;
}
