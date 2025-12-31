// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$upcomingAppointmentsStreamHash() =>
    r'b79c4c7f26af586a156c4a42e5ebf19ca3231837';

/// Stream provider for real-time upcoming appointments.
///
/// Copied from [upcomingAppointmentsStream].
@ProviderFor(upcomingAppointmentsStream)
final upcomingAppointmentsStreamProvider =
    AutoDisposeStreamProvider<List<Map<String, dynamic>>>.internal(
  upcomingAppointmentsStream,
  name: r'upcomingAppointmentsStreamProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$upcomingAppointmentsStreamHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpcomingAppointmentsStreamRef
    = AutoDisposeStreamProviderRef<List<Map<String, dynamic>>>;
String _$patientDashboardControllerHash() =>
    r'612f44cf32cdcec952a0de28289e55a64f8362fb';

/// Controller for the Patient Dashboard.
///
/// Manages appointment data for patients, including loading, canceling,
/// and submitting reviews.
///
/// Copied from [PatientDashboardController].
@ProviderFor(PatientDashboardController)
final patientDashboardControllerProvider = AutoDisposeAsyncNotifierProvider<
    PatientDashboardController, PatientDashboardState>.internal(
  PatientDashboardController.new,
  name: r'patientDashboardControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$patientDashboardControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$PatientDashboardController
    = AutoDisposeAsyncNotifier<PatientDashboardState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
