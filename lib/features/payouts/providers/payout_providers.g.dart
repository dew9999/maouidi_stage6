// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payout_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$payoutServiceHash() => r'f2326a781df2d452a6ba042d5e1baec25edcf3ec';

/// Provider for payout service
///
/// Copied from [payoutService].
@ProviderFor(payoutService)
final payoutServiceProvider = AutoDisposeProvider<PayoutService>.internal(
  payoutService,
  name: r'payoutServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$payoutServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef PayoutServiceRef = AutoDisposeProviderRef<PayoutService>;
String _$currentPeriodEarningsHash() =>
    r'8b29aff1bc71f8ca0da0f3e14c65c34ca124d2a3';

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

/// Provider for current period earnings
///
/// Copied from [currentPeriodEarnings].
@ProviderFor(currentPeriodEarnings)
const currentPeriodEarningsProvider = CurrentPeriodEarningsFamily();

/// Provider for current period earnings
///
/// Copied from [currentPeriodEarnings].
class CurrentPeriodEarningsFamily
    extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for current period earnings
  ///
  /// Copied from [currentPeriodEarnings].
  const CurrentPeriodEarningsFamily();

  /// Provider for current period earnings
  ///
  /// Copied from [currentPeriodEarnings].
  CurrentPeriodEarningsProvider call(
    String partnerId,
  ) {
    return CurrentPeriodEarningsProvider(
      partnerId,
    );
  }

  @override
  CurrentPeriodEarningsProvider getProviderOverride(
    covariant CurrentPeriodEarningsProvider provider,
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
  String? get name => r'currentPeriodEarningsProvider';
}

/// Provider for current period earnings
///
/// Copied from [currentPeriodEarnings].
class CurrentPeriodEarningsProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>> {
  /// Provider for current period earnings
  ///
  /// Copied from [currentPeriodEarnings].
  CurrentPeriodEarningsProvider(
    String partnerId,
  ) : this._internal(
          (ref) => currentPeriodEarnings(
            ref as CurrentPeriodEarningsRef,
            partnerId,
          ),
          from: currentPeriodEarningsProvider,
          name: r'currentPeriodEarningsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$currentPeriodEarningsHash,
          dependencies: CurrentPeriodEarningsFamily._dependencies,
          allTransitiveDependencies:
              CurrentPeriodEarningsFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  CurrentPeriodEarningsProvider._internal(
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
  Override overrideWith(
    FutureOr<Map<String, dynamic>> Function(CurrentPeriodEarningsRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CurrentPeriodEarningsProvider._internal(
        (ref) => create(ref as CurrentPeriodEarningsRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>> createElement() {
    return _CurrentPeriodEarningsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CurrentPeriodEarningsProvider &&
        other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin CurrentPeriodEarningsRef
    on AutoDisposeFutureProviderRef<Map<String, dynamic>> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _CurrentPeriodEarningsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>>
    with CurrentPeriodEarningsRef {
  _CurrentPeriodEarningsProviderElement(super.provider);

  @override
  String get partnerId => (origin as CurrentPeriodEarningsProvider).partnerId;
}

String _$payoutHistoryHash() => r'767efc35156f38e5b7187b583b7b4dc44913eaec';

/// Provider for payout history
///
/// Copied from [payoutHistory].
@ProviderFor(payoutHistory)
const payoutHistoryProvider = PayoutHistoryFamily();

/// Provider for payout history
///
/// Copied from [payoutHistory].
class PayoutHistoryFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider for payout history
  ///
  /// Copied from [payoutHistory].
  const PayoutHistoryFamily();

  /// Provider for payout history
  ///
  /// Copied from [payoutHistory].
  PayoutHistoryProvider call(
    String partnerId,
  ) {
    return PayoutHistoryProvider(
      partnerId,
    );
  }

  @override
  PayoutHistoryProvider getProviderOverride(
    covariant PayoutHistoryProvider provider,
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
  String? get name => r'payoutHistoryProvider';
}

/// Provider for payout history
///
/// Copied from [payoutHistory].
class PayoutHistoryProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider for payout history
  ///
  /// Copied from [payoutHistory].
  PayoutHistoryProvider(
    String partnerId,
  ) : this._internal(
          (ref) => payoutHistory(
            ref as PayoutHistoryRef,
            partnerId,
          ),
          from: payoutHistoryProvider,
          name: r'payoutHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$payoutHistoryHash,
          dependencies: PayoutHistoryFamily._dependencies,
          allTransitiveDependencies:
              PayoutHistoryFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  PayoutHistoryProvider._internal(
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
  Override overrideWith(
    FutureOr<List<Map<String, dynamic>>> Function(PayoutHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PayoutHistoryProvider._internal(
        (ref) => create(ref as PayoutHistoryRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _PayoutHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PayoutHistoryProvider && other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PayoutHistoryRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _PayoutHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with PayoutHistoryRef {
  _PayoutHistoryProviderElement(super.provider);

  @override
  String get partnerId => (origin as PayoutHistoryProvider).partnerId;
}

String _$lifetimeEarningsHash() => r'0673b08db4eaece7e8c740ad0a09306c455ffc5f';

/// Provider for lifetime earnings
///
/// Copied from [lifetimeEarnings].
@ProviderFor(lifetimeEarnings)
const lifetimeEarningsProvider = LifetimeEarningsFamily();

/// Provider for lifetime earnings
///
/// Copied from [lifetimeEarnings].
class LifetimeEarningsFamily extends Family<AsyncValue<double>> {
  /// Provider for lifetime earnings
  ///
  /// Copied from [lifetimeEarnings].
  const LifetimeEarningsFamily();

  /// Provider for lifetime earnings
  ///
  /// Copied from [lifetimeEarnings].
  LifetimeEarningsProvider call(
    String partnerId,
  ) {
    return LifetimeEarningsProvider(
      partnerId,
    );
  }

  @override
  LifetimeEarningsProvider getProviderOverride(
    covariant LifetimeEarningsProvider provider,
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
  String? get name => r'lifetimeEarningsProvider';
}

/// Provider for lifetime earnings
///
/// Copied from [lifetimeEarnings].
class LifetimeEarningsProvider extends AutoDisposeFutureProvider<double> {
  /// Provider for lifetime earnings
  ///
  /// Copied from [lifetimeEarnings].
  LifetimeEarningsProvider(
    String partnerId,
  ) : this._internal(
          (ref) => lifetimeEarnings(
            ref as LifetimeEarningsRef,
            partnerId,
          ),
          from: lifetimeEarningsProvider,
          name: r'lifetimeEarningsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$lifetimeEarningsHash,
          dependencies: LifetimeEarningsFamily._dependencies,
          allTransitiveDependencies:
              LifetimeEarningsFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  LifetimeEarningsProvider._internal(
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
  Override overrideWith(
    FutureOr<double> Function(LifetimeEarningsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: LifetimeEarningsProvider._internal(
        (ref) => create(ref as LifetimeEarningsRef),
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
  AutoDisposeFutureProviderElement<double> createElement() {
    return _LifetimeEarningsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is LifetimeEarningsProvider && other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin LifetimeEarningsRef on AutoDisposeFutureProviderRef<double> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _LifetimeEarningsProviderElement
    extends AutoDisposeFutureProviderElement<double> with LifetimeEarningsRef {
  _LifetimeEarningsProviderElement(super.provider);

  @override
  String get partnerId => (origin as LifetimeEarningsProvider).partnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
