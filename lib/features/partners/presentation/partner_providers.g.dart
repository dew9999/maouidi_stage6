// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$partnerListHash() => r'f71853b7011f85e0b4c11bea364615658eddab29';

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

/// Provider for filtered partner list.
///
/// Returns a list of medical partners filtered by category, state, and specialty.
/// Uses Riverpod's automatic caching and invalidation.
///
/// Copied from [partnerList].
@ProviderFor(partnerList)
const partnerListProvider = PartnerListFamily();

/// Provider for filtered partner list.
///
/// Returns a list of medical partners filtered by category, state, and specialty.
/// Uses Riverpod's automatic caching and invalidation.
///
/// Copied from [partnerList].
class PartnerListFamily extends Family<AsyncValue<List<MedicalPartnersRow>>> {
  /// Provider for filtered partner list.
  ///
  /// Returns a list of medical partners filtered by category, state, and specialty.
  /// Uses Riverpod's automatic caching and invalidation.
  ///
  /// Copied from [partnerList].
  const PartnerListFamily();

  /// Provider for filtered partner list.
  ///
  /// Returns a list of medical partners filtered by category, state, and specialty.
  /// Uses Riverpod's automatic caching and invalidation.
  ///
  /// Copied from [partnerList].
  PartnerListProvider call(
    PartnerListParams params,
  ) {
    return PartnerListProvider(
      params,
    );
  }

  @override
  PartnerListProvider getProviderOverride(
    covariant PartnerListProvider provider,
  ) {
    return call(
      provider.params,
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
  String? get name => r'partnerListProvider';
}

/// Provider for filtered partner list.
///
/// Returns a list of medical partners filtered by category, state, and specialty.
/// Uses Riverpod's automatic caching and invalidation.
///
/// Copied from [partnerList].
class PartnerListProvider
    extends AutoDisposeFutureProvider<List<MedicalPartnersRow>> {
  /// Provider for filtered partner list.
  ///
  /// Returns a list of medical partners filtered by category, state, and specialty.
  /// Uses Riverpod's automatic caching and invalidation.
  ///
  /// Copied from [partnerList].
  PartnerListProvider(
    PartnerListParams params,
  ) : this._internal(
          (ref) => partnerList(
            ref as PartnerListRef,
            params,
          ),
          from: partnerListProvider,
          name: r'partnerListProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partnerListHash,
          dependencies: PartnerListFamily._dependencies,
          allTransitiveDependencies:
              PartnerListFamily._allTransitiveDependencies,
          params: params,
        );

  PartnerListProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.params,
  }) : super.internal();

  final PartnerListParams params;

  @override
  Override overrideWith(
    FutureOr<List<MedicalPartnersRow>> Function(PartnerListRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PartnerListProvider._internal(
        (ref) => create(ref as PartnerListRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        params: params,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MedicalPartnersRow>> createElement() {
    return _PartnerListProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartnerListProvider && other.params == params;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, params.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PartnerListRef on AutoDisposeFutureProviderRef<List<MedicalPartnersRow>> {
  /// The parameter `params` of this provider.
  PartnerListParams get params;
}

class _PartnerListProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicalPartnersRow>>
    with PartnerListRef {
  _PartnerListProviderElement(super.provider);

  @override
  PartnerListParams get params => (origin as PartnerListProvider).params;
}

String _$partnerSearchHash() => r'a713ad83189b3c4dca57960446bca8ee41da81df';

/// Provider for partner search.
///
/// Returns a list of medical partners matching the search term.
/// Returns empty list for null or empty search terms.
///
/// Copied from [partnerSearch].
@ProviderFor(partnerSearch)
const partnerSearchProvider = PartnerSearchFamily();

/// Provider for partner search.
///
/// Returns a list of medical partners matching the search term.
/// Returns empty list for null or empty search terms.
///
/// Copied from [partnerSearch].
class PartnerSearchFamily extends Family<AsyncValue<List<MedicalPartnersRow>>> {
  /// Provider for partner search.
  ///
  /// Returns a list of medical partners matching the search term.
  /// Returns empty list for null or empty search terms.
  ///
  /// Copied from [partnerSearch].
  const PartnerSearchFamily();

  /// Provider for partner search.
  ///
  /// Returns a list of medical partners matching the search term.
  /// Returns empty list for null or empty search terms.
  ///
  /// Copied from [partnerSearch].
  PartnerSearchProvider call(
    String? searchTerm,
  ) {
    return PartnerSearchProvider(
      searchTerm,
    );
  }

  @override
  PartnerSearchProvider getProviderOverride(
    covariant PartnerSearchProvider provider,
  ) {
    return call(
      provider.searchTerm,
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
  String? get name => r'partnerSearchProvider';
}

/// Provider for partner search.
///
/// Returns a list of medical partners matching the search term.
/// Returns empty list for null or empty search terms.
///
/// Copied from [partnerSearch].
class PartnerSearchProvider
    extends AutoDisposeFutureProvider<List<MedicalPartnersRow>> {
  /// Provider for partner search.
  ///
  /// Returns a list of medical partners matching the search term.
  /// Returns empty list for null or empty search terms.
  ///
  /// Copied from [partnerSearch].
  PartnerSearchProvider(
    String? searchTerm,
  ) : this._internal(
          (ref) => partnerSearch(
            ref as PartnerSearchRef,
            searchTerm,
          ),
          from: partnerSearchProvider,
          name: r'partnerSearchProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partnerSearchHash,
          dependencies: PartnerSearchFamily._dependencies,
          allTransitiveDependencies:
              PartnerSearchFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  PartnerSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchTerm,
  }) : super.internal();

  final String? searchTerm;

  @override
  Override overrideWith(
    FutureOr<List<MedicalPartnersRow>> Function(PartnerSearchRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PartnerSearchProvider._internal(
        (ref) => create(ref as PartnerSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<MedicalPartnersRow>> createElement() {
    return _PartnerSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartnerSearchProvider && other.searchTerm == searchTerm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchTerm.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PartnerSearchRef
    on AutoDisposeFutureProviderRef<List<MedicalPartnersRow>> {
  /// The parameter `searchTerm` of this provider.
  String? get searchTerm;
}

class _PartnerSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<MedicalPartnersRow>>
    with PartnerSearchRef {
  _PartnerSearchProviderElement(super.provider);

  @override
  String? get searchTerm => (origin as PartnerSearchProvider).searchTerm;
}

String _$featuredPartnersHash() => r'c529efc3c8156a9b4196e06f031244d959ef5be7';

/// Provider for featured partners on home screen.
///
/// Returns a list of top 6 partners ordered by rating.
/// Uses Riverpod's automatic caching and invalidation.
///
/// Copied from [featuredPartners].
@ProviderFor(featuredPartners)
final featuredPartnersProvider =
    AutoDisposeFutureProvider<List<MedicalPartnersRow>>.internal(
  featuredPartners,
  name: r'featuredPartnersProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$featuredPartnersHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FeaturedPartnersRef
    = AutoDisposeFutureProviderRef<List<MedicalPartnersRow>>;
String _$partnerByIdHash() => r'2eed5c317e55c7d125ff179607e7f239d7c41ee7';

/// Provider for a single partner by ID.
///
/// Returns partner details for the profile page.
/// Returns null if partner not found.
///
/// Copied from [partnerById].
@ProviderFor(partnerById)
const partnerByIdProvider = PartnerByIdFamily();

/// Provider for a single partner by ID.
///
/// Returns partner details for the profile page.
/// Returns null if partner not found.
///
/// Copied from [partnerById].
class PartnerByIdFamily extends Family<AsyncValue<MedicalPartnersRow?>> {
  /// Provider for a single partner by ID.
  ///
  /// Returns partner details for the profile page.
  /// Returns null if partner not found.
  ///
  /// Copied from [partnerById].
  const PartnerByIdFamily();

  /// Provider for a single partner by ID.
  ///
  /// Returns partner details for the profile page.
  /// Returns null if partner not found.
  ///
  /// Copied from [partnerById].
  PartnerByIdProvider call(
    String partnerId,
  ) {
    return PartnerByIdProvider(
      partnerId,
    );
  }

  @override
  PartnerByIdProvider getProviderOverride(
    covariant PartnerByIdProvider provider,
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
  String? get name => r'partnerByIdProvider';
}

/// Provider for a single partner by ID.
///
/// Returns partner details for the profile page.
/// Returns null if partner not found.
///
/// Copied from [partnerById].
class PartnerByIdProvider
    extends AutoDisposeFutureProvider<MedicalPartnersRow?> {
  /// Provider for a single partner by ID.
  ///
  /// Returns partner details for the profile page.
  /// Returns null if partner not found.
  ///
  /// Copied from [partnerById].
  PartnerByIdProvider(
    String partnerId,
  ) : this._internal(
          (ref) => partnerById(
            ref as PartnerByIdRef,
            partnerId,
          ),
          from: partnerByIdProvider,
          name: r'partnerByIdProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$partnerByIdHash,
          dependencies: PartnerByIdFamily._dependencies,
          allTransitiveDependencies:
              PartnerByIdFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  PartnerByIdProvider._internal(
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
    FutureOr<MedicalPartnersRow?> Function(PartnerByIdRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: PartnerByIdProvider._internal(
        (ref) => create(ref as PartnerByIdRef),
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
  AutoDisposeFutureProviderElement<MedicalPartnersRow?> createElement() {
    return _PartnerByIdProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PartnerByIdProvider && other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin PartnerByIdRef on AutoDisposeFutureProviderRef<MedicalPartnersRow?> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _PartnerByIdProviderElement
    extends AutoDisposeFutureProviderElement<MedicalPartnersRow?>
    with PartnerByIdRef {
  _PartnerByIdProviderElement(super.provider);

  @override
  String get partnerId => (origin as PartnerByIdProvider).partnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
