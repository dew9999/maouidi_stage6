// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'345989e5e31a6448837e036e42eaa6e9d24d5e9d';

/// Riverpod-managed GoRouter with auth guards and role-based redirects.
///
/// Features:
/// - Automatically redirects unauthenticated users to /welcomeScreen
/// - Prevents authenticated users from accessing login screens
/// - Redirects authenticated users to appropriate dashboard based on role
///
/// Copied from [router].
@ProviderFor(router)
final routerProvider = AutoDisposeProvider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
