// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'patient_dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PatientDashboardState {
  List<Map<String, dynamic>> get upcomingAppointments =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get completedAppointments =>
      throw _privateConstructorUsedError;
  List<Map<String, dynamic>> get canceledAppointments =>
      throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PatientDashboardStateCopyWith<PatientDashboardState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientDashboardStateCopyWith<$Res> {
  factory $PatientDashboardStateCopyWith(PatientDashboardState value,
          $Res Function(PatientDashboardState) then) =
      _$PatientDashboardStateCopyWithImpl<$Res, PatientDashboardState>;
  @useResult
  $Res call(
      {List<Map<String, dynamic>> upcomingAppointments,
      List<Map<String, dynamic>> completedAppointments,
      List<Map<String, dynamic>> canceledAppointments,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$PatientDashboardStateCopyWithImpl<$Res,
        $Val extends PatientDashboardState>
    implements $PatientDashboardStateCopyWith<$Res> {
  _$PatientDashboardStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upcomingAppointments = null,
    Object? completedAppointments = null,
    Object? canceledAppointments = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      upcomingAppointments: null == upcomingAppointments
          ? _value.upcomingAppointments
          : upcomingAppointments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      completedAppointments: null == completedAppointments
          ? _value.completedAppointments
          : completedAppointments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      canceledAppointments: null == canceledAppointments
          ? _value.canceledAppointments
          : canceledAppointments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PatientDashboardStateImplCopyWith<$Res>
    implements $PatientDashboardStateCopyWith<$Res> {
  factory _$$PatientDashboardStateImplCopyWith(
          _$PatientDashboardStateImpl value,
          $Res Function(_$PatientDashboardStateImpl) then) =
      __$$PatientDashboardStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<Map<String, dynamic>> upcomingAppointments,
      List<Map<String, dynamic>> completedAppointments,
      List<Map<String, dynamic>> canceledAppointments,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$PatientDashboardStateImplCopyWithImpl<$Res>
    extends _$PatientDashboardStateCopyWithImpl<$Res,
        _$PatientDashboardStateImpl>
    implements _$$PatientDashboardStateImplCopyWith<$Res> {
  __$$PatientDashboardStateImplCopyWithImpl(_$PatientDashboardStateImpl _value,
      $Res Function(_$PatientDashboardStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? upcomingAppointments = null,
    Object? completedAppointments = null,
    Object? canceledAppointments = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PatientDashboardStateImpl(
      upcomingAppointments: null == upcomingAppointments
          ? _value._upcomingAppointments
          : upcomingAppointments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      completedAppointments: null == completedAppointments
          ? _value._completedAppointments
          : completedAppointments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      canceledAppointments: null == canceledAppointments
          ? _value._canceledAppointments
          : canceledAppointments // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$PatientDashboardStateImpl implements _PatientDashboardState {
  const _$PatientDashboardStateImpl(
      {final List<Map<String, dynamic>> upcomingAppointments = const [],
      final List<Map<String, dynamic>> completedAppointments = const [],
      final List<Map<String, dynamic>> canceledAppointments = const [],
      this.isLoading = false,
      this.errorMessage})
      : _upcomingAppointments = upcomingAppointments,
        _completedAppointments = completedAppointments,
        _canceledAppointments = canceledAppointments;

  final List<Map<String, dynamic>> _upcomingAppointments;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get upcomingAppointments {
    if (_upcomingAppointments is EqualUnmodifiableListView)
      return _upcomingAppointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_upcomingAppointments);
  }

  final List<Map<String, dynamic>> _completedAppointments;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get completedAppointments {
    if (_completedAppointments is EqualUnmodifiableListView)
      return _completedAppointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_completedAppointments);
  }

  final List<Map<String, dynamic>> _canceledAppointments;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get canceledAppointments {
    if (_canceledAppointments is EqualUnmodifiableListView)
      return _canceledAppointments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_canceledAppointments);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PatientDashboardState(upcomingAppointments: $upcomingAppointments, completedAppointments: $completedAppointments, canceledAppointments: $canceledAppointments, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientDashboardStateImpl &&
            const DeepCollectionEquality()
                .equals(other._upcomingAppointments, _upcomingAppointments) &&
            const DeepCollectionEquality()
                .equals(other._completedAppointments, _completedAppointments) &&
            const DeepCollectionEquality()
                .equals(other._canceledAppointments, _canceledAppointments) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_upcomingAppointments),
      const DeepCollectionEquality().hash(_completedAppointments),
      const DeepCollectionEquality().hash(_canceledAppointments),
      isLoading,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientDashboardStateImplCopyWith<_$PatientDashboardStateImpl>
      get copyWith => __$$PatientDashboardStateImplCopyWithImpl<
          _$PatientDashboardStateImpl>(this, _$identity);
}

abstract class _PatientDashboardState implements PatientDashboardState {
  const factory _PatientDashboardState(
      {final List<Map<String, dynamic>> upcomingAppointments,
      final List<Map<String, dynamic>> completedAppointments,
      final List<Map<String, dynamic>> canceledAppointments,
      final bool isLoading,
      final String? errorMessage}) = _$PatientDashboardStateImpl;

  @override
  List<Map<String, dynamic>> get upcomingAppointments;
  @override
  List<Map<String, dynamic>> get completedAppointments;
  @override
  List<Map<String, dynamic>> get canceledAppointments;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PatientDashboardStateImplCopyWith<_$PatientDashboardStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
