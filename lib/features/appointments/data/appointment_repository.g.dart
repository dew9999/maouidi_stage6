// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appointmentRepositoryHash() =>
    r'6516c0424a16cbfe1b4707b9c945a33c7566a0dd';

/// Repository for appointment-related operations (Database 2.0).
///
/// Now uses unified `appointments` table for ALL booking types.
///
/// Copied from [appointmentRepository].
@ProviderFor(appointmentRepository)
final appointmentRepositoryProvider =
    AutoDisposeProvider<AppointmentRepository>.internal(
  appointmentRepository,
  name: r'appointmentRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appointmentRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppointmentRepositoryRef
    = AutoDisposeProviderRef<AppointmentRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
