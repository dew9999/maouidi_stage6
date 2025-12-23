// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointments_stream_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appointmentsStreamHash() =>
    r'a0feb0ea97fd86f422bd076454cda223a9a62330';

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

/// Provides a real-time stream of appointments for a specific partner.
///
/// This stream uses Supabase Realtime to automatically update when
/// appointments are added, modified, or deleted. Partners will see
/// new bookings instantly without refreshing.
///
/// Copied from [appointmentsStream].
@ProviderFor(appointmentsStream)
const appointmentsStreamProvider = AppointmentsStreamFamily();

/// Provides a real-time stream of appointments for a specific partner.
///
/// This stream uses Supabase Realtime to automatically update when
/// appointments are added, modified, or deleted. Partners will see
/// new bookings instantly without refreshing.
///
/// Copied from [appointmentsStream].
class AppointmentsStreamFamily
    extends Family<AsyncValue<List<AppointmentModel>>> {
  /// Provides a real-time stream of appointments for a specific partner.
  ///
  /// This stream uses Supabase Realtime to automatically update when
  /// appointments are added, modified, or deleted. Partners will see
  /// new bookings instantly without refreshing.
  ///
  /// Copied from [appointmentsStream].
  const AppointmentsStreamFamily();

  /// Provides a real-time stream of appointments for a specific partner.
  ///
  /// This stream uses Supabase Realtime to automatically update when
  /// appointments are added, modified, or deleted. Partners will see
  /// new bookings instantly without refreshing.
  ///
  /// Copied from [appointmentsStream].
  AppointmentsStreamProvider call(
    String partnerId,
  ) {
    return AppointmentsStreamProvider(
      partnerId,
    );
  }

  @override
  AppointmentsStreamProvider getProviderOverride(
    covariant AppointmentsStreamProvider provider,
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
  String? get name => r'appointmentsStreamProvider';
}

/// Provides a real-time stream of appointments for a specific partner.
///
/// This stream uses Supabase Realtime to automatically update when
/// appointments are added, modified, or deleted. Partners will see
/// new bookings instantly without refreshing.
///
/// Copied from [appointmentsStream].
class AppointmentsStreamProvider
    extends AutoDisposeStreamProvider<List<AppointmentModel>> {
  /// Provides a real-time stream of appointments for a specific partner.
  ///
  /// This stream uses Supabase Realtime to automatically update when
  /// appointments are added, modified, or deleted. Partners will see
  /// new bookings instantly without refreshing.
  ///
  /// Copied from [appointmentsStream].
  AppointmentsStreamProvider(
    String partnerId,
  ) : this._internal(
          (ref) => appointmentsStream(
            ref as AppointmentsStreamRef,
            partnerId,
          ),
          from: appointmentsStreamProvider,
          name: r'appointmentsStreamProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$appointmentsStreamHash,
          dependencies: AppointmentsStreamFamily._dependencies,
          allTransitiveDependencies:
              AppointmentsStreamFamily._allTransitiveDependencies,
          partnerId: partnerId,
        );

  AppointmentsStreamProvider._internal(
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
    Stream<List<AppointmentModel>> Function(AppointmentsStreamRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AppointmentsStreamProvider._internal(
        (ref) => create(ref as AppointmentsStreamRef),
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
  AutoDisposeStreamProviderElement<List<AppointmentModel>> createElement() {
    return _AppointmentsStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AppointmentsStreamProvider && other.partnerId == partnerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, partnerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin AppointmentsStreamRef
    on AutoDisposeStreamProviderRef<List<AppointmentModel>> {
  /// The parameter `partnerId` of this provider.
  String get partnerId;
}

class _AppointmentsStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<AppointmentModel>>
    with AppointmentsStreamRef {
  _AppointmentsStreamProviderElement(super.provider);

  @override
  String get partnerId => (origin as AppointmentsStreamProvider).partnerId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
