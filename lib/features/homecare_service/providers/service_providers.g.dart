// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$serviceRepositoryHash() => r'66748892248b1a71c07e97a2e22d70741a2cbf8f';

/// Provider for service repository
///
/// Copied from [serviceRepository].
@ProviderFor(serviceRepository)
final serviceRepositoryProvider =
    AutoDisposeProvider<ServiceRepository>.internal(
  serviceRepository,
  name: r'serviceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$serviceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ServiceRepositoryRef = AutoDisposeProviderRef<ServiceRepository>;
String _$serviceStatusHash() => r'bdec7a021696d65a38bb57d0b62724bcfed79e0d';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for service status of a specific request
///
/// Copied from [serviceStatus].
@ProviderFor(serviceStatus)
const serviceStatusProvider = ServiceStatusFamily();

/// Provider for service status of a specific request
///
/// Copied from [serviceStatus].
class ServiceStatusFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for service status of a specific request
  ///
  /// Copied from [serviceStatus].
  const ServiceStatusFamily();

  /// Provider for service status of a specific request
  ///
  /// Copied from [serviceStatus].
  ServiceStatusProvider call(
    String requestId,
  ) {
    return ServiceStatusProvider(
      requestId,
    );
  }

  @override
  ServiceStatusProvider getProviderOverride(
    covariant ServiceStatusProvider provider,
  ) {
    return call(
      provider.requestId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'serviceStatusProvider';
}

/// Provider for service status of a specific request
///
/// Copied from [serviceStatus].
class ServiceStatusProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for service status of a specific request
  ///
  /// Copied from [serviceStatus].
  ServiceStatusProvider(
    String requestId,
  ) : this._internal(
          (ref) => serviceStatus(
            ref as ServiceStatusRef,
            requestId,
          ),
          from: serviceStatusProvider,
          name: r'serviceStatusProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$serviceStatusHash,
          dependencies: ServiceStatusFamily._dependencies,
          allTransitiveDependencies:
              ServiceStatusFamily._allTransitiveDependencies,
          requestId: requestId,
        );

  ServiceStatusProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.requestId,
  }) : super.internal();

  final String requestId;

  @override
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(ServiceStatusRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ServiceStatusProvider._internal(
        (ref) => create(ref as ServiceStatusRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        requestId: requestId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _ServiceStatusProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceStatusProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ServiceStatusRef on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _ServiceStatusProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with ServiceStatusRef {
  _ServiceStatusProviderElement(super.provider);

  @override
  String get requestId => (origin as ServiceStatusProvider).requestId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
