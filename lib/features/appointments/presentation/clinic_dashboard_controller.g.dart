// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clinic_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$clinicDashboardControllerHash() =>
    r'7bf7f8ce912235cfa1dbae7d4fad6151d91562ff';

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

abstract class _$ClinicDashboardController
    extends BuildlessAutoDisposeAsyncNotifier<ClinicDashboardState> {
  late final String clinicId;

  FutureOr<ClinicDashboardState> build(
    String clinicId,
  );
}

/// See also [ClinicDashboardController].
@ProviderFor(ClinicDashboardController)
const clinicDashboardControllerProvider = ClinicDashboardControllerFamily();

/// See also [ClinicDashboardController].
class ClinicDashboardControllerFamily
    extends Family<AsyncValue<ClinicDashboardState>> {
  /// See also [ClinicDashboardController].
  const ClinicDashboardControllerFamily();

  /// See also [ClinicDashboardController].
  ClinicDashboardControllerProvider call(
    String clinicId,
  ) {
    return ClinicDashboardControllerProvider(
      clinicId,
    );
  }

  @override
  ClinicDashboardControllerProvider getProviderOverride(
    covariant ClinicDashboardControllerProvider provider,
  ) {
    return call(
      provider.clinicId,
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
  String? get name => r'clinicDashboardControllerProvider';
}

/// See also [ClinicDashboardController].
class ClinicDashboardControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<ClinicDashboardController,
        ClinicDashboardState> {
  /// See also [ClinicDashboardController].
  ClinicDashboardControllerProvider(
    String clinicId,
  ) : this._internal(
          () => ClinicDashboardController()..clinicId = clinicId,
          from: clinicDashboardControllerProvider,
          name: r'clinicDashboardControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$clinicDashboardControllerHash,
          dependencies: ClinicDashboardControllerFamily._dependencies,
          allTransitiveDependencies:
              ClinicDashboardControllerFamily._allTransitiveDependencies,
          clinicId: clinicId,
        );

  ClinicDashboardControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.clinicId,
  }) : super.internal();

  final String clinicId;

  @override
  FutureOr<ClinicDashboardState> runNotifierBuild(
    covariant ClinicDashboardController notifier,
  ) {
    return notifier.build(
      clinicId,
    );
  }

  @override
  Override overrideWith(ClinicDashboardController Function() create) {
    return ProviderOverride(
      origin: this,
      override: ClinicDashboardControllerProvider._internal(
        () => create()..clinicId = clinicId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        clinicId: clinicId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<ClinicDashboardController,
      ClinicDashboardState> createElement() {
    return _ClinicDashboardControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ClinicDashboardControllerProvider &&
        other.clinicId == clinicId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, clinicId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ClinicDashboardControllerRef
    on AutoDisposeAsyncNotifierProviderRef<ClinicDashboardState> {
  /// The parameter `clinicId` of this provider.
  String get clinicId;
}

class _ClinicDashboardControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<ClinicDashboardController,
        ClinicDashboardState> with ClinicDashboardControllerRef {
  _ClinicDashboardControllerProviderElement(super.provider);

  @override
  String get clinicId => (origin as ClinicDashboardControllerProvider).clinicId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
