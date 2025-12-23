// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$bookingControllerHash() => r'0052ee5ecb6fc2bab73810cffc3b1f8eeed1768c';

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

abstract class _$BookingController
    extends BuildlessAutoDisposeNotifier<BookingState> {
  late final String partnerId;

  BookingState build(
    String partnerId,
  );
}

/// Controller for managing the complete booking flow.
///
/// Manages UI state including date selection, slot availability, and booking confirmation.
///
/// Copied from [BookingController].
@ProviderFor(BookingController)
const bookingControllerProvider = BookingControllerFamily();

/// Controller for managing the complete booking flow.
///
/// Manages UI state including date selection, slot availability, and booking confirmation.
///
/// Copied from [BookingController].
class BookingControllerFamily extends Family<BookingState> {
  /// Controller for managing the complete booking flow.
  ///
  /// Manages UI state including date selection, slot availability, and booking confirmation.
  ///
  /// Copied from [BookingController].
  const BookingControllerFamily();

  /// Controller for managing the complete booking flow.
  ///
  /// Manages UI state including date selection, slot availability, and booking confirmation.
  ///
  /// Copied from [BookingController].
  BookingControllerProvider call(
    String partnerId,
  ) {
    return BookingControllerProvider(
      partnerId,
    );
  }

  @override
  BookingControllerProvider getProviderOverride(
    covariant BookingControllerProvider provider,
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
  String? get name => r'bookingControllerProvider';
}

/// Controller for managing the complete booking flow.
///
/// Manages UI state including date selection, slot availability, and booking confirmation.
///
/// Copied from [BookingController].
class BookingControllerProvider
    extends AutoDisposeNotifierProviderImpl<BookingController, BookingState> {
  /// Controller for managing the complete booking flow.
  ///
  /// Manages UI state including date selection, slot availability, and booking confirmation.
  ///
  /// Copied from [BookingController].
  BookingControllerProvider(
    String partnerId,
  ) : this._internal(
          () => BookingController()..partnerId = partnerId,
          from: bookingControllerProvider,
          name: r'bookingControllerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$bookingControllerHash,
          dependencies: BookingControllerFamily._dependencies,
          allTransitiveDependencies:
              BookingControllerFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  BookingControllerProvider._internal(
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
  BookingState runNotifierBuild(
    covariant BookingController notifier,
  ) {
    return notifier.build(
      partnerId,
    );
  }

  @override
  Override overrideWith(BookingController Function() create) {
    return ProviderOverride(
      origin: this,
      override: BookingControllerProvider._internal(
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
  AutoDisposeNotifierProviderElement<BookingController, BookingState>
      createElement() {
    return _BookingControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BookingControllerProvider && other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin BookingControllerRef on AutoDisposeNotifierProviderRef<BookingState> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _BookingControllerProviderElement
    extends AutoDisposeNotifierProviderElement<BookingController, BookingState>
    with BookingControllerRef {
  _BookingControllerProviderElement(super.provider);

  @override
  String get partnerId => (origin as BookingControllerProvider).partnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
