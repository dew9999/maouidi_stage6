// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PartnerDashboardState {
  /// All appointments for the partner
  List<AppointmentModel> get appointments => throw _privateConstructorUsedError;

  /// Today's appointments (filtered by date)
  List<AppointmentModel> get todayAppointments =>
      throw _privateConstructorUsedError;

  /// Dashboard statistics (pending, completed, etc.)
  Map<String, int> get stats => throw _privateConstructorUsedError;

  /// Current patient being served (for queue-based systems)
  AppointmentModel? get currentPatient => throw _privateConstructorUsedError;

  /// Loading state
  bool get isLoading => throw _privateConstructorUsedError;

  /// Current view selection ('schedule' or 'analytics')
  String get selectedView => throw _privateConstructorUsedError;

  /// Current status filter ('Pending', 'Confirmed', 'Completed', 'Canceled')
  String get selectedStatus => throw _privateConstructorUsedError;

  /// Selected date for calendar view
  DateTime? get selectedDate => throw _privateConstructorUsedError;

  /// Error message if any operation fails
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PartnerDashboardStateCopyWith<PartnerDashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerDashboardStateCopyWith<$Res> {
  factory $PartnerDashboardStateCopyWith(PartnerDashboardState value,
          $Res Function(PartnerDashboardState) then) =
      _$PartnerDashboardStateCopyWithImpl<$Res, PartnerDashboardState>;
  @useResult
  $Res call(
      {List<AppointmentModel> appointments,
      List<AppointmentModel> todayAppointments,
      Map<String, int> stats,
      AppointmentModel? currentPatient,
      bool isLoading,
      String selectedView,
      String selectedStatus,
      DateTime? selectedDate,
      String? errorMessage});

  $AppointmentModelCopyWith<$Res>? get currentPatient;
}

/// @nodoc
class _$PartnerDashboardStateCopyWithImpl<$Res,
        $Val extends PartnerDashboardState>
    implements $PartnerDashboardStateCopyWith<$Res> {
  _$PartnerDashboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appointments = null,
    Object? todayAppointments = null,
    Object? stats = null,
    Object? currentPatient = freezed,
    Object? isLoading = null,
    Object? selectedView = null,
    Object? selectedStatus = null,
    Object? selectedDate = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      appointments: null == appointments
          ? _value.appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      todayAppointments: null == todayAppointments
          ? _value.todayAppointments
          : todayAppointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      stats: null == stats
          ? _value.stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      currentPatient: freezed == currentPatient
          ? _value.currentPatient
          : currentPatient // ignore: cast_nullable_to_non_nullable
              as AppointmentModel?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedView: null == selectedView
          ? _value.selectedView
          : selectedView // ignore: cast_nullable_to_non_nullable
              as String,
      selectedStatus: null == selectedStatus
          ? _value.selectedStatus
          : selectedStatus // ignore: cast_nullable_to_non_nullable
              as String,
      selectedDate: freezed == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AppointmentModelCopyWith<$Res>? get currentPatient {
    if (_value.currentPatient == null) {
      return null;
    }

    return $AppointmentModelCopyWith<$Res>(_value.currentPatient!, (value) {
      return _then(_value.copyWith(currentPatient: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PartnerDashboardStateImplCopyWith<$Res>
    implements $PartnerDashboardStateCopyWith<$Res> {
  factory _$$PartnerDashboardStateImplCopyWith(
          _$PartnerDashboardStateImpl value,
          $Res Function(_$PartnerDashboardStateImpl) then) =
      __$$PartnerDashboardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<AppointmentModel> appointments,
      List<AppointmentModel> todayAppointments,
      Map<String, int> stats,
      AppointmentModel? currentPatient,
      bool isLoading,
      String selectedView,
      String selectedStatus,
      DateTime? selectedDate,
      String? errorMessage});

  @override
  $AppointmentModelCopyWith<$Res>? get currentPatient;
}

/// @nodoc
class __$$PartnerDashboardStateImplCopyWithImpl<$Res>
    extends _$PartnerDashboardStateCopyWithImpl<$Res,
        _$PartnerDashboardStateImpl>
    implements _$$PartnerDashboardStateImplCopyWith<$Res> {
  __$$PartnerDashboardStateImplCopyWithImpl(_$PartnerDashboardStateImpl _value,
      $Res Function(_$PartnerDashboardStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? appointments = null,
    Object? todayAppointments = null,
    Object? stats = null,
    Object? currentPatient = freezed,
    Object? isLoading = null,
    Object? selectedView = null,
    Object? selectedStatus = null,
    Object? selectedDate = freezed,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PartnerDashboardStateImpl(
      appointments: null == appointments
          ? _value._appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      todayAppointments: null == todayAppointments
          ? _value._todayAppointments
          : todayAppointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      stats: null == stats
          ? _value._stats
          : stats // ignore: cast_nullable_to_non_nullable
              as Map<String, int>,
      currentPatient: freezed == currentPatient
          ? _value.currentPatient
          : currentPatient // ignore: cast_nullable_to_non_nullable
              as AppointmentModel?,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      selectedView: null == selectedView
          ? _value.selectedView
          : selectedView // ignore: cast_nullable_to_non_nullable
              as String,
      selectedStatus: null == selectedStatus
          ? _value.selectedStatus
          : selectedStatus // ignore: cast_nullable_to_non_nullable
              as String,
      selectedDate: freezed == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PartnerDashboardStateImpl implements _PartnerDashboardState {
  const _$PartnerDashboardStateImpl(
      {final List<AppointmentModel> appointments = const [],
      final List<AppointmentModel> todayAppointments = const [],
      final Map<String, int> stats = const {},
      this.currentPatient,
      this.isLoading = false,
      this.selectedView = 'schedule',
      this.selectedStatus = 'Confirmed',
      this.selectedDate,
      this.errorMessage})
      : _appointments = appointments,
        _todayAppointments = todayAppointments,
        _stats = stats;

  /// All appointments for the partner
  final List<AppointmentModel> _appointments;

  /// All appointments for the partner
  @override
  @JsonKey()
  List<AppointmentModel> get appointments {
    if (_appointments is EqualUnmodifiableListView) return _appointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appointments);
  }

  /// Today's appointments (filtered by date)
  final List<AppointmentModel> _todayAppointments;

  /// Today's appointments (filtered by date)
  @override
  @JsonKey()
  List<AppointmentModel> get todayAppointments {
    if (_todayAppointments is EqualUnmodifiableListView)
      return _todayAppointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_todayAppointments);
  }

  /// Dashboard statistics (pending, completed, etc.)
  final Map<String, int> _stats;

  /// Dashboard statistics (pending, completed, etc.)
  @override
  @JsonKey()
  Map<String, int> get stats {
    if (_stats is EqualUnmodifiableMapView) return _stats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_stats);
  }

  /// Current patient being served (for queue-based systems)
  @override
  final AppointmentModel? currentPatient;

  /// Loading state
  @override
  @JsonKey()
  final bool isLoading;

  /// Current view selection ('schedule' or 'analytics')
  @override
  @JsonKey()
  final String selectedView;

  /// Current status filter ('Pending', 'Confirmed', 'Completed', 'Canceled')
  @override
  @JsonKey()
  final String selectedStatus;

  /// Selected date for calendar view
  @override
  final DateTime? selectedDate;

  /// Error message if any operation fails
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PartnerDashboardState(appointments: $appointments, todayAppointments: $todayAppointments, stats: $stats, currentPatient: $currentPatient, isLoading: $isLoading, selectedView: $selectedView, selectedStatus: $selectedStatus, selectedDate: $selectedDate, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerDashboardStateImpl &&
            const DeepCollectionEquality()
                .equals(other._appointments, _appointments) &&
            const DeepCollectionEquality()
                .equals(other._todayAppointments, _todayAppointments) &&
            const DeepCollectionEquality().equals(other._stats, _stats) &&
            (identical(other.currentPatient, currentPatient) ||
                other.currentPatient == currentPatient) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.selectedView, selectedView) ||
                other.selectedView == selectedView) &&
            (identical(other.selectedStatus, selectedStatus) ||
                other.selectedStatus == selectedStatus) &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_appointments),
      const DeepCollectionEquality().hash(_todayAppointments),
      const DeepCollectionEquality().hash(_stats),
      currentPatient,
      isLoading,
      selectedView,
      selectedStatus,
      selectedDate,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerDashboardStateImplCopyWith<_$PartnerDashboardStateImpl>
      get copyWith => __$$PartnerDashboardStateImplCopyWithImpl<
          _$PartnerDashboardStateImpl>(this, _$identity);
}

abstract class _PartnerDashboardState implements PartnerDashboardState {
  const factory _PartnerDashboardState(
      {final List<AppointmentModel> appointments,
      final List<AppointmentModel> todayAppointments,
      final Map<String, int> stats,
      final AppointmentModel? currentPatient,
      final bool isLoading,
      final String selectedView,
      final String selectedStatus,
      final DateTime? selectedDate,
      final String? errorMessage}) = _$PartnerDashboardStateImpl;

  @override

  /// All appointments for the partner
  List<AppointmentModel> get appointments;
  @override

  /// Today's appointments (filtered by date)
  List<AppointmentModel> get todayAppointments;
  @override

  /// Dashboard statistics (pending, completed, etc.)
  Map<String, int> get stats;
  @override

  /// Current patient being served (for queue-based systems)
  AppointmentModel? get currentPatient;
  @override

  /// Loading state
  bool get isLoading;
  @override

  /// Current view selection ('schedule' or 'analytics')
  String get selectedView;
  @override

  /// Current status filter ('Pending', 'Confirmed', 'Completed', 'Canceled')
  String get selectedStatus;
  @override

  /// Selected date for calendar view
  DateTime? get selectedDate;
  @override

  /// Error message if any operation fails
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PartnerDashboardStateImplCopyWith<_$PartnerDashboardStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
