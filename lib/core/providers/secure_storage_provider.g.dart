// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_storage_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$secureStorageHash() => r'4be6b8e938943bbd2e8ffecb03f97737bfa1effc';

/// Provides a secure storage instance configured for maximum security
/// Uses platform-native keychains (iOS Keychain, Android Keystore)
///
/// Copied from [secureStorage].
@ProviderFor(secureStorage)
final secureStorageProvider =
    AutoDisposeProvider<FlutterSecureStorage>.internal(
  secureStorage,
  name: r'secureStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SecureStorageRef = AutoDisposeProviderRef<FlutterSecureStorage>;
String _$secureStorageHelperHash() =>
    r'e0d377f085913415e73a492fa8818e38881d8c17';

/// Example helper methods for common secure storage operations
/// Usage: ref.read(secureStorageHelperProvider).saveToken(token);
///
/// Copied from [secureStorageHelper].
@ProviderFor(secureStorageHelper)
final secureStorageHelperProvider =
    AutoDisposeProvider<SecureStorageHelper>.internal(
  secureStorageHelper,
  name: r'secureStorageHelperProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$secureStorageHelperHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SecureStorageHelperRef = AutoDisposeProviderRef<SecureStorageHelper>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
