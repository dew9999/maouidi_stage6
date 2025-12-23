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
  List<AppointmentModel> get appointments => throw _privateConstructorUsedError;
  String get selectedView => throw _privateConstructorUsedError;
  String get selectedStatus => throw _privateConstructorUsedError;
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
      String selectedView,
      String selectedStatus,
      String? errorMessage});
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
    Object? selectedView = null,
    Object? selectedStatus = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      appointments: null == appointments
          ? _value.appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      selectedView: null == selectedView
          ? _value.selectedView
          : selectedView // ignore: cast_nullable_to_non_nullable
              as String,
      selectedStatus: null == selectedStatus
          ? _value.selectedStatus
          : selectedStatus // ignore: cast_nullable_to_non_nullable
              as String,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
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
      String selectedView,
      String selectedStatus,
      String? errorMessage});
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
    Object? selectedView = null,
    Object? selectedStatus = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PartnerDashboardStateImpl(
      appointments: null == appointments
          ? _value._appointments
          : appointments // ignore: cast_nullable_to_non_nullable
              as List<AppointmentModel>,
      selectedView: null == selectedView
          ? _value.selectedView
          : selectedView // ignore: cast_nullable_to_non_nullable
              as String,
      selectedStatus: null == selectedStatus
          ? _value.selectedStatus
          : selectedStatus // ignore: cast_nullable_to_non_nullable
              as String,
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
      {required final List<AppointmentModel> appointments,
      this.selectedView = 'schedule',
      this.selectedStatus = 'Pending',
      this.errorMessage})
      : _appointments = appointments;

  final List<AppointmentModel> _appointments;
  @override
  List<AppointmentModel> get appointments {
    if (_appointments is EqualUnmodifiableListView) return _appointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_appointments);
  }

  @override
  @JsonKey()
  final String selectedView;
  @override
  @JsonKey()
  final String selectedStatus;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PartnerDashboardState(appointments: $appointments, selectedView: $selectedView, selectedStatus: $selectedStatus, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerDashboardStateImpl &&
            const DeepCollectionEquality()
                .equals(other._appointments, _appointments) &&
            (identical(other.selectedView, selectedView) ||
                other.selectedView == selectedView) &&
            (identical(other.selectedStatus, selectedStatus) ||
                other.selectedStatus == selectedStatus) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_appointments),
      selectedView,
      selectedStatus,
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
      {required final List<AppointmentModel> appointments,
      final String selectedView,
      final String selectedStatus,
      final String? errorMessage}) = _$PartnerDashboardStateImpl;

  @override
  List<AppointmentModel> get appointments;
  @override
  String get selectedView;
  @override
  String get selectedStatus;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PartnerDashboardStateImplCopyWith<_$PartnerDashboardStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
