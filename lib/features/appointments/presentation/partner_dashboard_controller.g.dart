// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partnerDashboardControllerHash() =>
    r'fd592d4ed12e9cdab1b6ae53c1792347ce91ed73';

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

abstract class _$PartnerDashboardController
    extends BuildlessAutoDisposeAsyncNotifier<PartnerDashboardState> {
  late final String partnerId;

  FutureOr<PartnerDashboardState> build(
    String partnerId,
  );
}

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
/// Uses AsyncNotifier to handle asynchronous state updates.
///
/// Copied from [PartnerDashboardController].
@ProviderFor(PartnerDashboardController)
const partnerDashboardControllerProvider = PartnerDashboardControllerFamily();

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
/// Uses AsyncNotifier to handle asynchronous state updates.
///
/// Copied from [PartnerDashboardController].
class PartnerDashboardControllerFamily
    extends Family<AsyncValue<PartnerDashboardState>> {
  /// Controller for the Partner Dashboard.
  ///
  /// Manages appointment state and provides actions for appointment management.
  /// Uses AsyncNotifier to handle asynchronous state updates.
  ///
  /// Copied from [PartnerDashboardController].
  const PartnerDashboardControllerFamily();

  /// Controller for the Partner Dashboard.
  ///
  /// Manages appointment state and provides actions for appointment management.
  /// Uses AsyncNotifier to handle asynchronous state updates.
  ///
  /// Copied from [PartnerDashboardController].
  PartnerDashboardControllerProvider call(
    String partnerId,
  ) {
    return PartnerDashboardControllerProvider(
      partnerId,
    );
  }

  @override
  PartnerDashboardControllerProvider getProviderOverride(
    covariant PartnerDashboardControllerProvider provider,
  ) {
    return call(
      provider.partnerId,
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
  String? get name => r'partnerDashboardControllerProvider';
}

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
/// Uses AsyncNotifier to handle asynchronous state updates.
///
/// Copied from [PartnerDashboardController].
class PartnerDashboardControllerProvider
    extends AutoDisposeAsyncNotifierProviderImpl<PartnerDashboardController,
        PartnerDashboardState> {
  /// Controller for the Partner Dashboard.
  ///
  /// Manages appointment state and provides actions for appointment management.
  /// Uses AsyncNotifier to handle asynchronous state updates.
  ///
  /// Copied from [PartnerDashboardController].
  PartnerDashboardControllerProvider(
    String partnerId,
  ) : this._internal(
          () => PartnerDashboardController()..partnerId = partnerId,
          from: partnerDashboardControllerProvider,
          name: r'partnerDashboardControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partnerDashboardControllerHash,
          dependencies: PartnerDashboardControllerFamily._dependencies,
          allTransitiveDependencies:
              PartnerDashboardControllerFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  PartnerDashboardControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.partnerId,
  }) : super.internal();

  final String partnerId;

  @override
  FutureOr<PartnerDashboardState> runNotifierBuild(
    covariant PartnerDashboardController notifier,
  ) {
    return notifier.build(
      partnerId,
    );
  }

  @override
  Override overrideWith(PartnerDashboardController Function() create) {
    return ProviderOverride(
      origin: this,
      override: PartnerDashboardControllerProvider._internal(
        () => create()..partnerId = partnerId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        partnerId: partnerId,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<PartnerDashboardController,
      PartnerDashboardState> createElement() {
    return _PartnerDashboardControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartnerDashboardControllerProvider &&
        other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PartnerDashboardControllerRef
    on AutoDisposeAsyncNotifierProviderRef<PartnerDashboardState> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _PartnerDashboardControllerProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<PartnerDashboardController,
        PartnerDashboardState> with PartnerDashboardControllerRef {
  _PartnerDashboardControllerProviderElement(super.provider);

  @override
  String get partnerId =>
      (origin as PartnerDashboardControllerProvider).partnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
