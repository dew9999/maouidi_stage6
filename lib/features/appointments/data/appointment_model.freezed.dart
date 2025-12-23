// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AppointmentModel _$AppointmentModelFromJson(Map<String, dynamic> json) {
  return _AppointmentModel.fromJson(json);
}

/// @nodoc
mixin _$AppointmentModel {
  int get id => throw _privateConstructorUsedError;
  String get partnerId => throw _privateConstructorUsedError;
  String get bookingUserId => throw _privateConstructorUsedError;
  String? get onBehalfOfPatientName => throw _privateConstructorUsedError;
  DateTime get appointmentTime => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  String? get onBehalfOfPatientPhone => throw _privateConstructorUsedError;
  int? get appointmentNumber => throw _privateConstructorUsedError;
  bool get isRescheduled => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  bool get hasReview => throw _privateConstructorUsedError;
  String? get caseDescription => throw _privateConstructorUsedError;
  String? get patientLocation => throw _privateConstructorUsedError;
  String? get patientFirstName => throw _privateConstructorUsedError;
  String? get patientLastName => throw _privateConstructorUsedError;
  String? get patientPhone => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AppointmentModelCopyWith<AppointmentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentModelCopyWith<$Res> {
  factory $AppointmentModelCopyWith(
          AppointmentModel value, $Res Function(AppointmentModel) then) =
      _$AppointmentModelCopyWithImpl<$Res, AppointmentModel>;
  @useResult
  $Res call(
      {int id,
      String partnerId,
      String bookingUserId,
      String? onBehalfOfPatientName,
      DateTime appointmentTime,
      String status,
      String? onBehalfOfPatientPhone,
      int? appointmentNumber,
      bool isRescheduled,
      DateTime? completedAt,
      bool hasReview,
      String? caseDescription,
      String? patientLocation,
      String? patientFirstName,
      String? patientLastName,
      String? patientPhone});
}

/// @nodoc
class _$AppointmentModelCopyWithImpl<$Res, $Val extends AppointmentModel>
    implements $AppointmentModelCopyWith<$Res> {
  _$AppointmentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partnerId = null,
    Object? bookingUserId = null,
    Object? onBehalfOfPatientName = freezed,
    Object? appointmentTime = null,
    Object? status = null,
    Object? onBehalfOfPatientPhone = freezed,
    Object? appointmentNumber = freezed,
    Object? isRescheduled = null,
    Object? completedAt = freezed,
    Object? hasReview = null,
    Object? caseDescription = freezed,
    Object? patientLocation = freezed,
    Object? patientFirstName = freezed,
    Object? patientLastName = freezed,
    Object? patientPhone = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      partnerId: null == partnerId
          ? _value.partnerId
          : partnerId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingUserId: null == bookingUserId
          ? _value.bookingUserId
          : bookingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      onBehalfOfPatientName: freezed == onBehalfOfPatientName
          ? _value.onBehalfOfPatientName
          : onBehalfOfPatientName // ignore: cast_nullable_to_non_nullable
              as String?,
      appointmentTime: null == appointmentTime
          ? _value.appointmentTime
          : appointmentTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      onBehalfOfPatientPhone: freezed == onBehalfOfPatientPhone
          ? _value.onBehalfOfPatientPhone
          : onBehalfOfPatientPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      appointmentNumber: freezed == appointmentNumber
          ? _value.appointmentNumber
          : appointmentNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      isRescheduled: null == isRescheduled
          ? _value.isRescheduled
          : isRescheduled // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasReview: null == hasReview
          ? _value.hasReview
          : hasReview // ignore: cast_nullable_to_non_nullable
              as bool,
      caseDescription: freezed == caseDescription
          ? _value.caseDescription
          : caseDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      patientLocation: freezed == patientLocation
          ? _value.patientLocation
          : patientLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      patientFirstName: freezed == patientFirstName
          ? _value.patientFirstName
          : patientFirstName // ignore: cast_nullable_to_non_nullable
              as String?,
      patientLastName: freezed == patientLastName
          ? _value.patientLastName
          : patientLastName // ignore: cast_nullable_to_non_nullable
              as String?,
      patientPhone: freezed == patientPhone
          ? _value.patientPhone
          : patientPhone // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AppointmentModelImplCopyWith<$Res>
    implements $AppointmentModelCopyWith<$Res> {
  factory _$$AppointmentModelImplCopyWith(_$AppointmentModelImpl value,
          $Res Function(_$AppointmentModelImpl) then) =
      __$$AppointmentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String partnerId,
      String bookingUserId,
      String? onBehalfOfPatientName,
      DateTime appointmentTime,
      String status,
      String? onBehalfOfPatientPhone,
      int? appointmentNumber,
      bool isRescheduled,
      DateTime? completedAt,
      bool hasReview,
      String? caseDescription,
      String? patientLocation,
      String? patientFirstName,
      String? patientLastName,
      String? patientPhone});
}

/// @nodoc
class __$$AppointmentModelImplCopyWithImpl<$Res>
    extends _$AppointmentModelCopyWithImpl<$Res, _$AppointmentModelImpl>
    implements _$$AppointmentModelImplCopyWith<$Res> {
  __$$AppointmentModelImplCopyWithImpl(_$AppointmentModelImpl _value,
      $Res Function(_$AppointmentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? partnerId = null,
    Object? bookingUserId = null,
    Object? onBehalfOfPatientName = freezed,
    Object? appointmentTime = null,
    Object? status = null,
    Object? onBehalfOfPatientPhone = freezed,
    Object? appointmentNumber = freezed,
    Object? isRescheduled = null,
    Object? completedAt = freezed,
    Object? hasReview = null,
    Object? caseDescription = freezed,
    Object? patientLocation = freezed,
    Object? patientFirstName = freezed,
    Object? patientLastName = freezed,
    Object? patientPhone = freezed,
  }) {
    return _then(_$AppointmentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      partnerId: null == partnerId
          ? _value.partnerId
          : partnerId // ignore: cast_nullable_to_non_nullable
              as String,
      bookingUserId: null == bookingUserId
          ? _value.bookingUserId
          : bookingUserId // ignore: cast_nullable_to_non_nullable
              as String,
      onBehalfOfPatientName: freezed == onBehalfOfPatientName
          ? _value.onBehalfOfPatientName
          : onBehalfOfPatientName // ignore: cast_nullable_to_non_nullable
              as String?,
      appointmentTime: null == appointmentTime
          ? _value.appointmentTime
          : appointmentTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as String,
      onBehalfOfPatientPhone: freezed == onBehalfOfPatientPhone
          ? _value.onBehalfOfPatientPhone
          : onBehalfOfPatientPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      appointmentNumber: freezed == appointmentNumber
          ? _value.appointmentNumber
          : appointmentNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      isRescheduled: null == isRescheduled
          ? _value.isRescheduled
          : isRescheduled // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hasReview: null == hasReview
          ? _value.hasReview
          : hasReview // ignore: cast_nullable_to_non_nullable
              as bool,
      caseDescription: freezed == caseDescription
          ? _value.caseDescription
          : caseDescription // ignore: cast_nullable_to_non_nullable
              as String?,
      patientLocation: freezed == patientLocation
          ? _value.patientLocation
          : patientLocation // ignore: cast_nullable_to_non_nullable
              as String?,
      patientFirstName: freezed == patientFirstName
          ? _value.patientFirstName
          : patientFirstName // ignore: cast_nullable_to_non_nullable
              as String?,
      patientLastName: freezed == patientLastName
          ? _value.patientLastName
          : patientLastName // ignore: cast_nullable_to_non_nullable
              as String?,
      patientPhone: freezed == patientPhone
          ? _value.patientPhone
          : patientPhone // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentModelImpl implements _AppointmentModel {
  const _$AppointmentModelImpl(
      {required this.id,
      required this.partnerId,
      required this.bookingUserId,
      this.onBehalfOfPatientName,
      required this.appointmentTime,
      required this.status,
      this.onBehalfOfPatientPhone,
      this.appointmentNumber,
      this.isRescheduled = false,
      this.completedAt,
      this.hasReview = false,
      this.caseDescription,
      this.patientLocation,
      this.patientFirstName,
      this.patientLastName,
      this.patientPhone});

  factory _$AppointmentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentModelImplFromJson(json);

  @override
  final int id;
  @override
  final String partnerId;
  @override
  final String bookingUserId;
  @override
  final String? onBehalfOfPatientName;
  @override
  final DateTime appointmentTime;
  @override
  final String status;
  @override
  final String? onBehalfOfPatientPhone;
  @override
  final int? appointmentNumber;
  @override
  @JsonKey()
  final bool isRescheduled;
  @override
  final DateTime? completedAt;
  @override
  @JsonKey()
  final bool hasReview;
  @override
  final String? caseDescription;
  @override
  final String? patientLocation;
  @override
  final String? patientFirstName;
  @override
  final String? patientLastName;
  @override
  final String? patientPhone;

  @override
  String toString() {
    return 'AppointmentModel(id: $id, partnerId: $partnerId, bookingUserId: $bookingUserId, onBehalfOfPatientName: $onBehalfOfPatientName, appointmentTime: $appointmentTime, status: $status, onBehalfOfPatientPhone: $onBehalfOfPatientPhone, appointmentNumber: $appointmentNumber, isRescheduled: $isRescheduled, completedAt: $completedAt, hasReview: $hasReview, caseDescription: $caseDescription, patientLocation: $patientLocation, patientFirstName: $patientFirstName, patientLastName: $patientLastName, patientPhone: $patientPhone)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.partnerId, partnerId) ||
                other.partnerId == partnerId) &&
            (identical(other.bookingUserId, bookingUserId) ||
                other.bookingUserId == bookingUserId) &&
            (identical(other.onBehalfOfPatientName, onBehalfOfPatientName) ||
                other.onBehalfOfPatientName == onBehalfOfPatientName) &&
            (identical(other.appointmentTime, appointmentTime) ||
                other.appointmentTime == appointmentTime) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.onBehalfOfPatientPhone, onBehalfOfPatientPhone) ||
                other.onBehalfOfPatientPhone == onBehalfOfPatientPhone) &&
            (identical(other.appointmentNumber, appointmentNumber) ||
                other.appointmentNumber == appointmentNumber) &&
            (identical(other.isRescheduled, isRescheduled) ||
                other.isRescheduled == isRescheduled) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.hasReview, hasReview) ||
                other.hasReview == hasReview) &&
            (identical(other.caseDescription, caseDescription) ||
                other.caseDescription == caseDescription) &&
            (identical(other.patientLocation, patientLocation) ||
                other.patientLocation == patientLocation) &&
            (identical(other.patientFirstName, patientFirstName) ||
                other.patientFirstName == patientFirstName) &&
            (identical(other.patientLastName, patientLastName) ||
                other.patientLastName == patientLastName) &&
            (identical(other.patientPhone, patientPhone) ||
                other.patientPhone == patientPhone));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      partnerId,
      bookingUserId,
      onBehalfOfPatientName,
      appointmentTime,
      status,
      onBehalfOfPatientPhone,
      appointmentNumber,
      isRescheduled,
      completedAt,
      hasReview,
      caseDescription,
      patientLocation,
      patientFirstName,
      patientLastName,
      patientPhone);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      __$$AppointmentModelImplCopyWithImpl<_$AppointmentModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentModelImplToJson(
      this,
    );
  }
}

abstract class _AppointmentModel implements AppointmentModel {
  const factory _AppointmentModel(
      {required final int id,
      required final String partnerId,
      required final String bookingUserId,
      final String? onBehalfOfPatientName,
      required final DateTime appointmentTime,
      required final String status,
      final String? onBehalfOfPatientPhone,
      final int? appointmentNumber,
      final bool isRescheduled,
      final DateTime? completedAt,
      final bool hasReview,
      final String? caseDescription,
      final String? patientLocation,
      final String? patientFirstName,
      final String? patientLastName,
      final String? patientPhone}) = _$AppointmentModelImpl;

  factory _AppointmentModel.fromJson(Map<String, dynamic> json) =
      _$AppointmentModelImpl.fromJson;

  @override
  int get id;
  @override
  String get partnerId;
  @override
  String get bookingUserId;
  @override
  String? get onBehalfOfPatientName;
  @override
  DateTime get appointmentTime;
  @override
  String get status;
  @override
  String? get onBehalfOfPatientPhone;
  @override
  int? get appointmentNumber;
  @override
  bool get isRescheduled;
  @override
  DateTime? get completedAt;
  @override
  bool get hasReview;
  @override
  String? get caseDescription;
  @override
  String? get patientLocation;
  @override
  String? get patientFirstName;
  @override
  String? get patientLastName;
  @override
  String? get patientPhone;
  @override
  @JsonKey(ignore: true)
  _$$AppointmentModelImplCopyWith<_$AppointmentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
