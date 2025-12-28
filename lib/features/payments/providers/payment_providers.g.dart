// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chargilyPublicKeyHash() => r'80a51db795bb300b647f73d12b29a9dbb3bca503';

/// Provider for Chargily public key from Supabase config
/// NOTE: Secret key is NOT accessible from Flutter (security!)
/// Secret key is only available to Edge Functions via service role
///
/// Copied from [chargilyPublicKey].
@ProviderFor(chargilyPublicKey)
final chargilyPublicKeyProvider = AutoDisposeFutureProvider<String>.internal(
  chargilyPublicKey,
  name: r'chargilyPublicKeyProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chargilyPublicKeyHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChargilyPublicKeyRef = AutoDisposeFutureProviderRef<String>;
String _$chargilyServiceHash() => r'6d44ade4b6a2f3ce8ddfc641f4cce1b7e668eefd';

/// Provider for Chargily service (calls Edge Functions)
/// SECURE: All payments go through Edge Functions, secret key never exposed
///
/// Copied from [chargilyService].
@ProviderFor(chargilyService)
final chargilyServiceProvider =
    AutoDisposeFutureProvider<ChargilyService>.internal(
  chargilyService,
  name: r'chargilyServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chargilyServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ChargilyServiceRef = AutoDisposeFutureProviderRef<ChargilyService>;
String _$refundServiceHash() => r'0022c8d28631749e4ba050a9a07c2588a9bd4d0d';

/// Provider for refund service
/// NOTE: Refunds should also be processed via Edge Function for security
///
/// Copied from [refundService].
@ProviderFor(refundService)
final refundServiceProvider = AutoDisposeFutureProvider<RefundService>.internal(
  refundService,
  name: r'refundServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$refundServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RefundServiceRef = AutoDisposeFutureProviderRef<RefundService>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
