// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'negotiation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$negotiationRepositoryHash() =>
    r'015584f6bcf893045c09235ab7649f938a185d03';

/// Provider for negotiation repository
///
/// Copied from [negotiationRepository].
@ProviderFor(negotiationRepository)
final negotiationRepositoryProvider =
    AutoDisposeProvider<NegotiationRepository>.internal(
  negotiationRepository,
  name: r'negotiationRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$negotiationRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NegotiationRepositoryRef
    = AutoDisposeProviderRef<NegotiationRepository>;
String _$negotiationHistoryHash() =>
    r'91df7eb8a2d8dd83b9b656925f1fb62e84b7b49a';

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

/// Provider for negotiation history of a specific request
///
/// Copied from [negotiationHistory].
@ProviderFor(negotiationHistory)
const negotiationHistoryProvider = NegotiationHistoryFamily();

/// Provider for negotiation history of a specific request
///
/// Copied from [negotiationHistory].
class NegotiationHistoryFamily
    extends Family<AsyncValue<List<Map<String, dynamic>>>> {
  /// Provider for negotiation history of a specific request
  ///
  /// Copied from [negotiationHistory].
  const NegotiationHistoryFamily();

  /// Provider for negotiation history of a specific request
  ///
  /// Copied from [negotiationHistory].
  NegotiationHistoryProvider call(
    String requestId,
  ) {
    return NegotiationHistoryProvider(
      requestId,
    );
  }

  @override
  NegotiationHistoryProvider getProviderOverride(
    covariant NegotiationHistoryProvider provider,
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
  String? get name => r'negotiationHistoryProvider';
}

/// Provider for negotiation history of a specific request
///
/// Copied from [negotiationHistory].
class NegotiationHistoryProvider
    extends AutoDisposeFutureProvider<List<Map<String, dynamic>>> {
  /// Provider for negotiation history of a specific request
  ///
  /// Copied from [negotiationHistory].
  NegotiationHistoryProvider(
    String requestId,
  ) : this._internal(
          (ref) => negotiationHistory(
            ref as NegotiationHistoryRef,
            requestId,
          ),
          from: negotiationHistoryProvider,
          name: r'negotiationHistoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$negotiationHistoryHash,
          dependencies: NegotiationHistoryFamily._dependencies,
          allTransitiveDependencies:
              NegotiationHistoryFamily._allTransitiveDependencies,
          requestId: requestId,
        );

  NegotiationHistoryProvider._internal(
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
    FutureOr<List<Map<String, dynamic>>> Function(
            NegotiationHistoryRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: NegotiationHistoryProvider._internal(
        (ref) => create(ref as NegotiationHistoryRef),
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
  AutoDisposeFutureProviderElement<List<Map<String, dynamic>>> createElement() {
    return _NegotiationHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NegotiationHistoryProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NegotiationHistoryRef
    on AutoDisposeFutureProviderRef<List<Map<String, dynamic>>> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _NegotiationHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<Map<String, dynamic>>>
    with NegotiationHistoryRef {
  _NegotiationHistoryProviderElement(super.provider);

  @override
  String get requestId => (origin as NegotiationHistoryProvider).requestId;
}

String _$negotiationStateHash() => r'e27be73af3d14b5db333935c53c673bc59d28ad2';

abstract class _$NegotiationState
    extends BuildlessAutoDisposeAsyncNotifier<Map<String, dynamic>> {
  late final String requestId;

  FutureOr<Map<String, dynamic>> build(
    String requestId,
  );
}

/// Provider for negotiation state of a specific request
///
/// Copied from [NegotiationState].
@ProviderFor(NegotiationState)
const negotiationStateProvider = NegotiationStateFamily();

/// Provider for negotiation state of a specific request
///
/// Copied from [NegotiationState].
class NegotiationStateFamily extends Family<AsyncValue<Map<String, dynamic>>> {
  /// Provider for negotiation state of a specific request
  ///
  /// Copied from [NegotiationState].
  const NegotiationStateFamily();

  /// Provider for negotiation state of a specific request
  ///
  /// Copied from [NegotiationState].
  NegotiationStateProvider call(
    String requestId,
  ) {
    return NegotiationStateProvider(
      requestId,
    );
  }

  @override
  NegotiationStateProvider getProviderOverride(
    covariant NegotiationStateProvider provider,
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
  String? get name => r'negotiationStateProvider';
}

/// Provider for negotiation state of a specific request
///
/// Copied from [NegotiationState].
class NegotiationStateProvider extends AutoDisposeAsyncNotifierProviderImpl<
    NegotiationState, Map<String, dynamic>> {
  /// Provider for negotiation state of a specific request
  ///
  /// Copied from [NegotiationState].
  NegotiationStateProvider(
    String requestId,
  ) : this._internal(
          () => NegotiationState()..requestId = requestId,
          from: negotiationStateProvider,
          name: r'negotiationStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$negotiationStateHash,
          dependencies: NegotiationStateFamily._dependencies,
          allTransitiveDependencies:
              NegotiationStateFamily._allTransitiveDependencies,
          requestId: requestId,
        );

  NegotiationStateProvider._internal(
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
  FutureOr<Map<String, dynamic>> runNotifierBuild(
    covariant NegotiationState notifier,
  ) {
    return notifier.build(
      requestId,
    );
  }

  @override
  Override overrideWith(NegotiationState Function() create) {
    return ProviderOverride(
      origin: this,
      override: NegotiationStateProvider._internal(
        () => create()..requestId = requestId,
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
  AutoDisposeAsyncNotifierProviderElement<NegotiationState,
      Map<String, dynamic>> createElement() {
    return _NegotiationStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is NegotiationStateProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin NegotiationStateRef
    on AutoDisposeAsyncNotifierProviderRef<Map<String, dynamic>> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _NegotiationStateProviderElement
    extends AutoDisposeAsyncNotifierProviderElement<NegotiationState,
        Map<String, dynamic>> with NegotiationStateRef {
  _NegotiationStateProviderElement(super.provider);

  @override
  String get requestId => (origin as NegotiationStateProvider).requestId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
