// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partnerDashboardControllerHash() =>
    r'9986b2ed9e085b282efb03f5194944b882d43b97';

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
    extends BuildlessAutoDisposeNotifier<PartnerDashboardState> {
  late final String partnerId;

  PartnerDashboardState build(
    String partnerId,
  );
}

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
///
/// Copied from [PartnerDashboardController].
@ProviderFor(PartnerDashboardController)
const partnerDashboardControllerProvider = PartnerDashboardControllerFamily();

/// Controller for the Partner Dashboard.
///
/// Manages appointment state and provides actions for appointment management.
///
/// Copied from [PartnerDashboardController].
class PartnerDashboardControllerFamily extends Family<PartnerDashboardState> {
  /// Controller for the Partner Dashboard.
  ///
  /// Manages appointment state and provides actions for appointment management.
  ///
  /// Copied from [PartnerDashboardController].
  const PartnerDashboardControllerFamily();

  /// Controller for the Partner Dashboard.
  ///
  /// Manages appointment state and provides actions for appointment management.
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
///
/// Copied from [PartnerDashboardController].
class PartnerDashboardControllerProvider
    extends AutoDisposeNotifierProviderImpl<PartnerDashboardController,
        PartnerDashboardState> {
  /// Controller for the Partner Dashboard.
  ///
  /// Manages appointment state and provides actions for appointment management.
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
  PartnerDashboardState runNotifierBuild(
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
  AutoDisposeNotifierProviderElement<PartnerDashboardController,
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
    on AutoDisposeNotifierProviderRef<PartnerDashboardState> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _PartnerDashboardControllerProviderElement
    extends AutoDisposeNotifierProviderElement<PartnerDashboardController,
        PartnerDashboardState> with PartnerDashboardControllerRef {
  _PartnerDashboardControllerProviderElement(super.provider);

  @override
  String get partnerId =>
      (origin as PartnerDashboardControllerProvider).partnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
