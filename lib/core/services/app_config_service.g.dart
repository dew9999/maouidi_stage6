// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_config_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appConfigServiceHash() => r'6173124f6931930cd778a41c869a9fa462084962';

/// Provider for AppConfigService
///
/// Copied from [appConfigService].
@ProviderFor(appConfigService)
final appConfigServiceProvider = AutoDisposeProvider<AppConfigService>.internal(
  appConfigService,
  name: r'appConfigServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appConfigServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef AppConfigServiceRef = AutoDisposeProviderRef<AppConfigService>;
String _$platformFeeHash() => r'1f3b2688b3d7277ebb141be24966814c06128e8f';

/// Provider for platform fee (cached)
///
/// This provider automatically fetches and caches the platform fee
///
/// Copied from [platformFee].
@ProviderFor(platformFee)
final platformFeeProvider = AutoDisposeFutureProvider<double>.internal(
  platformFee,
  name: r'platformFeeProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$platformFeeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PlatformFeeRef = AutoDisposeFutureProviderRef<double>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
