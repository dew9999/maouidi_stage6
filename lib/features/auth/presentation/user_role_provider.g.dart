// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRoleHash() => r'f823c5ce7eab2aab87f9dfdf8dffc49487f7461b';

/// FutureProvider that reactively fetches the user's role.
///
/// Automatically refreshes when auth state changes.
/// Returns null if user is not authenticated.
///
/// Role values:
/// - 'Medical Partner' - User exists in medical_partners table
/// - 'Patient' - User exists only in users table
/// - null - User is not authenticated
///
/// Copied from [userRole].
@ProviderFor(userRole)
final userRoleProvider = AutoDisposeFutureProvider<String?>.internal(
  userRole,
  name: r'userRoleProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userRoleHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRoleRef = AutoDisposeFutureProviderRef<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
