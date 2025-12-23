// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'booking_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BookingState {
  DateTime get selectedDate => throw _privateConstructorUsedError;
  String? get selectedSlot => throw _privateConstructorUsedError;
  List<TimeSlot> get availableSlots => throw _privateConstructorUsedError;
  PartnerBookingData? get partnerData => throw _privateConstructorUsedError;
  bool get isLoadingSlots => throw _privateConstructorUsedError;
  bool get isLoadingPartner => throw _privateConstructorUsedError;
  BookingStatus get bookingStatus => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $BookingStateCopyWith<BookingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingStateCopyWith<$Res> {
  factory $BookingStateCopyWith(
          BookingState value, $Res Function(BookingState) then) =
      _$BookingStateCopyWithImpl<$Res, BookingState>;
  @useResult
  $Res call(
      {DateTime selectedDate,
      String? selectedSlot,
      List<TimeSlot> availableSlots,
      PartnerBookingData? partnerData,
      bool isLoadingSlots,
      bool isLoadingPartner,
      BookingStatus bookingStatus,
      String? errorMessage});
}

/// @nodoc
class _$BookingStateCopyWithImpl<$Res, $Val extends BookingState>
    implements $BookingStateCopyWith<$Res> {
  _$BookingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? selectedSlot = freezed,
    Object? availableSlots = null,
    Object? partnerData = freezed,
    Object? isLoadingSlots = null,
    Object? isLoadingPartner = null,
    Object? bookingStatus = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      selectedSlot: freezed == selectedSlot
          ? _value.selectedSlot
          : selectedSlot // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: null == availableSlots
          ? _value.availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      partnerData: freezed == partnerData
          ? _value.partnerData
          : partnerData // ignore: cast_nullable_to_non_nullable
              as PartnerBookingData?,
      isLoadingSlots: null == isLoadingSlots
          ? _value.isLoadingSlots
          : isLoadingSlots // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingPartner: null == isLoadingPartner
          ? _value.isLoadingPartner
          : isLoadingPartner // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BookingStateImplCopyWith<$Res>
    implements $BookingStateCopyWith<$Res> {
  factory _$$BookingStateImplCopyWith(
          _$BookingStateImpl value, $Res Function(_$BookingStateImpl) then) =
      __$$BookingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime selectedDate,
      String? selectedSlot,
      List<TimeSlot> availableSlots,
      PartnerBookingData? partnerData,
      bool isLoadingSlots,
      bool isLoadingPartner,
      BookingStatus bookingStatus,
      String? errorMessage});
}

/// @nodoc
class __$$BookingStateImplCopyWithImpl<$Res>
    extends _$BookingStateCopyWithImpl<$Res, _$BookingStateImpl>
    implements _$$BookingStateImplCopyWith<$Res> {
  __$$BookingStateImplCopyWithImpl(
      _$BookingStateImpl _value, $Res Function(_$BookingStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedDate = null,
    Object? selectedSlot = freezed,
    Object? availableSlots = null,
    Object? partnerData = freezed,
    Object? isLoadingSlots = null,
    Object? isLoadingPartner = null,
    Object? bookingStatus = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$BookingStateImpl(
      selectedDate: null == selectedDate
          ? _value.selectedDate
          : selectedDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      selectedSlot: freezed == selectedSlot
          ? _value.selectedSlot
          : selectedSlot // ignore: cast_nullable_to_non_nullable
              as String?,
      availableSlots: null == availableSlots
          ? _value._availableSlots
          : availableSlots // ignore: cast_nullable_to_non_nullable
              as List<TimeSlot>,
      partnerData: freezed == partnerData
          ? _value.partnerData
          : partnerData // ignore: cast_nullable_to_non_nullable
              as PartnerBookingData?,
      isLoadingSlots: null == isLoadingSlots
          ? _value.isLoadingSlots
          : isLoadingSlots // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoadingPartner: null == isLoadingPartner
          ? _value.isLoadingPartner
          : isLoadingPartner // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingStatus: null == bookingStatus
          ? _value.bookingStatus
          : bookingStatus // ignore: cast_nullable_to_non_nullable
              as BookingStatus,
      errorMessage: freezed == errorMessage
          ? _value.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$BookingStateImpl implements _BookingState {
  const _$BookingStateImpl(
      {required this.selectedDate,
      this.selectedSlot,
      final List<TimeSlot> availableSlots = const [],
      this.partnerData,
      this.isLoadingSlots = false,
      this.isLoadingPartner = false,
      this.bookingStatus = BookingStatus.initial,
      this.errorMessage})
      : _availableSlots = availableSlots;

  @override
  final DateTime selectedDate;
  @override
  final String? selectedSlot;
  final List<TimeSlot> _availableSlots;
  @override
  @JsonKey()
  List<TimeSlot> get availableSlots {
    if (_availableSlots is EqualUnmodifiableListView) return _availableSlots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_availableSlots);
  }

  @override
  final PartnerBookingData? partnerData;
  @override
  @JsonKey()
  final bool isLoadingSlots;
  @override
  @JsonKey()
  final bool isLoadingPartner;
  @override
  @JsonKey()
  final BookingStatus bookingStatus;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'BookingState(selectedDate: $selectedDate, selectedSlot: $selectedSlot, availableSlots: $availableSlots, partnerData: $partnerData, isLoadingSlots: $isLoadingSlots, isLoadingPartner: $isLoadingPartner, bookingStatus: $bookingStatus, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingStateImpl &&
            (identical(other.selectedDate, selectedDate) ||
                other.selectedDate == selectedDate) &&
            (identical(other.selectedSlot, selectedSlot) ||
                other.selectedSlot == selectedSlot) &&
            const DeepCollectionEquality()
                .equals(other._availableSlots, _availableSlots) &&
            (identical(other.partnerData, partnerData) ||
                other.partnerData == partnerData) &&
            (identical(other.isLoadingSlots, isLoadingSlots) ||
                other.isLoadingSlots == isLoadingSlots) &&
            (identical(other.isLoadingPartner, isLoadingPartner) ||
                other.isLoadingPartner == isLoadingPartner) &&
            (identical(other.bookingStatus, bookingStatus) ||
                other.bookingStatus == bookingStatus) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      selectedDate,
      selectedSlot,
      const DeepCollectionEquality().hash(_availableSlots),
      partnerData,
      isLoadingSlots,
      isLoadingPartner,
      bookingStatus,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BookingStateImplCopyWith<_$BookingStateImpl> get copyWith =>
      __$$BookingStateImplCopyWithImpl<_$BookingStateImpl>(this, _$identity);
}

abstract class _BookingState implements BookingState {
  const factory _BookingState(
      {required final DateTime selectedDate,
      final String? selectedSlot,
      final List<TimeSlot> availableSlots,
      final PartnerBookingData? partnerData,
      final bool isLoadingSlots,
      final bool isLoadingPartner,
      final BookingStatus bookingStatus,
      final String? errorMessage}) = _$BookingStateImpl;

  @override
  DateTime get selectedDate;
  @override
  String? get selectedSlot;
  @override
  List<TimeSlot> get availableSlots;
  @override
  PartnerBookingData? get partnerData;
  @override
  bool get isLoadingSlots;
  @override
  bool get isLoadingPartner;
  @override
  BookingStatus get bookingStatus;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$BookingStateImplCopyWith<_$BookingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
