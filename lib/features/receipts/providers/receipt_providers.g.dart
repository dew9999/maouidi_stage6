// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$receiptServiceHash() => r'17caee284311e6ae7befaa03e97fc05646eb9736';

/// Provider for receipt service
///
/// Copied from [receiptService].
@ProviderFor(receiptService)
final receiptServiceProvider = AutoDisposeProvider<ReceiptService>.internal(
  receiptService,
  name: r'receiptServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$receiptServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef ReceiptServiceRef = AutoDisposeProviderRef<ReceiptService>;
String _$receiptDataHash() => r'6c1c748bb5cc9195bffcbcff1ed471b6dae89066';

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

/// Provider for receipt data
///
/// Copied from [receiptData].
@ProviderFor(receiptData)
const receiptDataProvider = ReceiptDataFamily();

/// Provider for receipt data
///
/// Copied from [receiptData].
class ReceiptDataFamily extends Family<AsyncValue<Map<String, dynamic>?>> {
  /// Provider for receipt data
  ///
  /// Copied from [receiptData].
  const ReceiptDataFamily();

  /// Provider for receipt data
  ///
  /// Copied from [receiptData].
  ReceiptDataProvider call(
    String requestId,
  ) {
    return ReceiptDataProvider(
      requestId,
    );
  }

  @override
  ReceiptDataProvider getProviderOverride(
    covariant ReceiptDataProvider provider,
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
  String? get name => r'receiptDataProvider';
}

/// Provider for receipt data
///
/// Copied from [receiptData].
class ReceiptDataProvider
    extends AutoDisposeFutureProvider<Map<String, dynamic>?> {
  /// Provider for receipt data
  ///
  /// Copied from [receiptData].
  ReceiptDataProvider(
    String requestId,
  ) : this._internal(
          (ref) => receiptData(
            ref as ReceiptDataRef,
            requestId,
          ),
          from: receiptDataProvider,
          name: r'receiptDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$receiptDataHash,
          dependencies: ReceiptDataFamily._dependencies,
          allTransitiveDependencies:
              ReceiptDataFamily._allTransitiveDependencies,
          requestId: requestId,
        );

  ReceiptDataProvider._internal(
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
    FutureOr<Map<String, dynamic>?> Function(ReceiptDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ReceiptDataProvider._internal(
        (ref) => create(ref as ReceiptDataRef),
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
  AutoDisposeFutureProviderElement<Map<String, dynamic>?> createElement() {
    return _ReceiptDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ReceiptDataProvider && other.requestId == requestId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, requestId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin ReceiptDataRef on AutoDisposeFutureProviderRef<Map<String, dynamic>?> {
  /// The parameter `requestId` of this provider.
  String get requestId;
}

class _ReceiptDataProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, dynamic>?>
    with ReceiptDataRef {
  _ReceiptDataProviderElement(super.provider);

  @override
  String get requestId => (origin as ReceiptDataProvider).requestId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
