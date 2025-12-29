// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PatientSettingsState {
  String get displayName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get phoneNumber => throw _privateConstructorUsedError;
  String get photoUrl => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PatientSettingsStateCopyWith<PatientSettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PatientSettingsStateCopyWith<$Res> {
  factory $PatientSettingsStateCopyWith(PatientSettingsState value,
          $Res Function(PatientSettingsState) then) =
      _$PatientSettingsStateCopyWithImpl<$Res, PatientSettingsState>;
  @useResult
  $Res call(
      {String displayName,
      String email,
      String phoneNumber,
      String photoUrl,
      bool notificationsEnabled,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$PatientSettingsStateCopyWithImpl<$Res,
        $Val extends PatientSettingsState>
    implements $PatientSettingsStateCopyWith<$Res> {
  _$PatientSettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? photoUrl = null,
    Object? notificationsEnabled = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$PatientSettingsStateImplCopyWith<$Res>
    implements $PatientSettingsStateCopyWith<$Res> {
  factory _$$PatientSettingsStateImplCopyWith(_$PatientSettingsStateImpl value,
          $Res Function(_$PatientSettingsStateImpl) then) =
      __$$PatientSettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String displayName,
      String email,
      String phoneNumber,
      String photoUrl,
      bool notificationsEnabled,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$PatientSettingsStateImplCopyWithImpl<$Res>
    extends _$PatientSettingsStateCopyWithImpl<$Res, _$PatientSettingsStateImpl>
    implements _$$PatientSettingsStateImplCopyWith<$Res> {
  __$$PatientSettingsStateImplCopyWithImpl(_$PatientSettingsStateImpl _value,
      $Res Function(_$PatientSettingsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? email = null,
    Object? phoneNumber = null,
    Object? photoUrl = null,
    Object? notificationsEnabled = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PatientSettingsStateImpl(
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      photoUrl: null == photoUrl
          ? _value.photoUrl
          : photoUrl // ignore: cast_nullable_to_non_nullable
              as String,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
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

class _$PatientSettingsStateImpl implements _PatientSettingsState {
  const _$PatientSettingsStateImpl(
      {this.displayName = '',
      this.email = '',
      this.phoneNumber = '',
      this.photoUrl = '',
      this.notificationsEnabled = true,
      this.isLoading = false,
      this.errorMessage});

  @override
  @JsonKey()
  final String displayName;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String phoneNumber;
  @override
  @JsonKey()
  final String photoUrl;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PatientSettingsState(displayName: $displayName, email: $email, phoneNumber: $phoneNumber, photoUrl: $photoUrl, notificationsEnabled: $notificationsEnabled, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PatientSettingsStateImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.photoUrl, photoUrl) ||
                other.photoUrl == photoUrl) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, displayName, email, phoneNumber,
      photoUrl, notificationsEnabled, isLoading, errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PatientSettingsStateImplCopyWith<_$PatientSettingsStateImpl>
      get copyWith =>
          __$$PatientSettingsStateImplCopyWithImpl<_$PatientSettingsStateImpl>(
              this, _$identity);
}

abstract class _PatientSettingsState implements PatientSettingsState {
  const factory _PatientSettingsState(
      {final String displayName,
      final String email,
      final String phoneNumber,
      final String photoUrl,
      final bool notificationsEnabled,
      final bool isLoading,
      final String? errorMessage}) = _$PatientSettingsStateImpl;

  @override
  String get displayName;
  @override
  String get email;
  @override
  String get phoneNumber;
  @override
  String get photoUrl;
  @override
  bool get notificationsEnabled;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PatientSettingsStateImplCopyWith<_$PatientSettingsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$PartnerSettingsState {
  String get fullName => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError; // NEW: Bio field
  String? get phone => throw _privateConstructorUsedError; // From users table
  String? get state =>
      throw _privateConstructorUsedError; // From users table (wilaya/state)
  String get category => throw _privateConstructorUsedError;
  String? get specialty => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  bool get notificationsEnabled => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get bookingSystemType => throw _privateConstructorUsedError;
  String get confirmationMode => throw _privateConstructorUsedError;
  int get dailyBookingLimit => throw _privateConstructorUsedError;
  Map<String, List<String>> get workingHours =>
      throw _privateConstructorUsedError;
  List<DateTime> get closedDays => throw _privateConstructorUsedError;
  bool get isSaving => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PartnerSettingsStateCopyWith<PartnerSettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerSettingsStateCopyWith<$Res> {
  factory $PartnerSettingsStateCopyWith(PartnerSettingsState value,
          $Res Function(PartnerSettingsState) then) =
      _$PartnerSettingsStateCopyWithImpl<$Res, PartnerSettingsState>;
  @useResult
  $Res call(
      {String fullName,
      String email,
      String? bio,
      String? phone,
      String? state,
      String category,
      String? specialty,
      String? location,
      bool notificationsEnabled,
      bool isActive,
      String bookingSystemType,
      String confirmationMode,
      int dailyBookingLimit,
      Map<String, List<String>> workingHours,
      List<DateTime> closedDays,
      bool isSaving,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$PartnerSettingsStateCopyWithImpl<$Res,
        $Val extends PartnerSettingsState>
    implements $PartnerSettingsStateCopyWith<$Res> {
  _$PartnerSettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? email = null,
    Object? bio = freezed,
    Object? phone = freezed,
    Object? state = freezed,
    Object? category = null,
    Object? specialty = freezed,
    Object? location = freezed,
    Object? notificationsEnabled = null,
    Object? isActive = null,
    Object? bookingSystemType = null,
    Object? confirmationMode = null,
    Object? dailyBookingLimit = null,
    Object? workingHours = null,
    Object? closedDays = null,
    Object? isSaving = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: freezed == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingSystemType: null == bookingSystemType
          ? _value.bookingSystemType
          : bookingSystemType // ignore: cast_nullable_to_non_nullable
              as String,
      confirmationMode: null == confirmationMode
          ? _value.confirmationMode
          : confirmationMode // ignore: cast_nullable_to_non_nullable
              as String,
      dailyBookingLimit: null == dailyBookingLimit
          ? _value.dailyBookingLimit
          : dailyBookingLimit // ignore: cast_nullable_to_non_nullable
              as int,
      workingHours: null == workingHours
          ? _value.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      closedDays: null == closedDays
          ? _value.closedDays
          : closedDays // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
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
abstract class _$$PartnerSettingsStateImplCopyWith<$Res>
    implements $PartnerSettingsStateCopyWith<$Res> {
  factory _$$PartnerSettingsStateImplCopyWith(_$PartnerSettingsStateImpl value,
          $Res Function(_$PartnerSettingsStateImpl) then) =
      __$$PartnerSettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String fullName,
      String email,
      String? bio,
      String? phone,
      String? state,
      String category,
      String? specialty,
      String? location,
      bool notificationsEnabled,
      bool isActive,
      String bookingSystemType,
      String confirmationMode,
      int dailyBookingLimit,
      Map<String, List<String>> workingHours,
      List<DateTime> closedDays,
      bool isSaving,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$PartnerSettingsStateImplCopyWithImpl<$Res>
    extends _$PartnerSettingsStateCopyWithImpl<$Res, _$PartnerSettingsStateImpl>
    implements _$$PartnerSettingsStateImplCopyWith<$Res> {
  __$$PartnerSettingsStateImplCopyWithImpl(_$PartnerSettingsStateImpl _value,
      $Res Function(_$PartnerSettingsStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = null,
    Object? email = null,
    Object? bio = freezed,
    Object? phone = freezed,
    Object? state = freezed,
    Object? category = null,
    Object? specialty = freezed,
    Object? location = freezed,
    Object? notificationsEnabled = null,
    Object? isActive = null,
    Object? bookingSystemType = null,
    Object? confirmationMode = null,
    Object? dailyBookingLimit = null,
    Object? workingHours = null,
    Object? closedDays = null,
    Object? isSaving = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$PartnerSettingsStateImpl(
      fullName: null == fullName
          ? _value.fullName
          : fullName // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      specialty: freezed == specialty
          ? _value.specialty
          : specialty // ignore: cast_nullable_to_non_nullable
              as String?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      notificationsEnabled: null == notificationsEnabled
          ? _value.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      bookingSystemType: null == bookingSystemType
          ? _value.bookingSystemType
          : bookingSystemType // ignore: cast_nullable_to_non_nullable
              as String,
      confirmationMode: null == confirmationMode
          ? _value.confirmationMode
          : confirmationMode // ignore: cast_nullable_to_non_nullable
              as String,
      dailyBookingLimit: null == dailyBookingLimit
          ? _value.dailyBookingLimit
          : dailyBookingLimit // ignore: cast_nullable_to_non_nullable
              as int,
      workingHours: null == workingHours
          ? _value._workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as Map<String, List<String>>,
      closedDays: null == closedDays
          ? _value._closedDays
          : closedDays // ignore: cast_nullable_to_non_nullable
              as List<DateTime>,
      isSaving: null == isSaving
          ? _value.isSaving
          : isSaving // ignore: cast_nullable_to_non_nullable
              as bool,
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

class _$PartnerSettingsStateImpl implements _PartnerSettingsState {
  const _$PartnerSettingsStateImpl(
      {this.fullName = '',
      this.email = '',
      this.bio,
      this.phone,
      this.state,
      this.category = '',
      this.specialty,
      this.location,
      this.notificationsEnabled = true,
      this.isActive = false,
      this.bookingSystemType = 'time_based',
      this.confirmationMode = 'manual',
      this.dailyBookingLimit = 0,
      final Map<String, List<String>> workingHours = const {},
      final List<DateTime> closedDays = const [],
      this.isSaving = false,
      this.isLoading = false,
      this.errorMessage})
      : _workingHours = workingHours,
        _closedDays = closedDays;

  @override
  @JsonKey()
  final String fullName;
  @override
  @JsonKey()
  final String email;
  @override
  final String? bio;
// NEW: Bio field
  @override
  final String? phone;
// From users table
  @override
  final String? state;
// From users table (wilaya/state)
  @override
  @JsonKey()
  final String category;
  @override
  final String? specialty;
  @override
  final String? location;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final String bookingSystemType;
  @override
  @JsonKey()
  final String confirmationMode;
  @override
  @JsonKey()
  final int dailyBookingLimit;
  final Map<String, List<String>> _workingHours;
  @override
  @JsonKey()
  Map<String, List<String>> get workingHours {
    if (_workingHours is EqualUnmodifiableMapView) return _workingHours;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_workingHours);
  }

  final List<DateTime> _closedDays;
  @override
  @JsonKey()
  List<DateTime> get closedDays {
    if (_closedDays is EqualUnmodifiableListView) return _closedDays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_closedDays);
  }

  @override
  @JsonKey()
  final bool isSaving;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'PartnerSettingsState(fullName: $fullName, email: $email, bio: $bio, phone: $phone, state: $state, category: $category, specialty: $specialty, location: $location, notificationsEnabled: $notificationsEnabled, isActive: $isActive, bookingSystemType: $bookingSystemType, confirmationMode: $confirmationMode, dailyBookingLimit: $dailyBookingLimit, workingHours: $workingHours, closedDays: $closedDays, isSaving: $isSaving, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerSettingsStateImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.specialty, specialty) ||
                other.specialty == specialty) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.bookingSystemType, bookingSystemType) ||
                other.bookingSystemType == bookingSystemType) &&
            (identical(other.confirmationMode, confirmationMode) ||
                other.confirmationMode == confirmationMode) &&
            (identical(other.dailyBookingLimit, dailyBookingLimit) ||
                other.dailyBookingLimit == dailyBookingLimit) &&
            const DeepCollectionEquality()
                .equals(other._workingHours, _workingHours) &&
            const DeepCollectionEquality()
                .equals(other._closedDays, _closedDays) &&
            (identical(other.isSaving, isSaving) ||
                other.isSaving == isSaving) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      fullName,
      email,
      bio,
      phone,
      state,
      category,
      specialty,
      location,
      notificationsEnabled,
      isActive,
      bookingSystemType,
      confirmationMode,
      dailyBookingLimit,
      const DeepCollectionEquality().hash(_workingHours),
      const DeepCollectionEquality().hash(_closedDays),
      isSaving,
      isLoading,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerSettingsStateImplCopyWith<_$PartnerSettingsStateImpl>
      get copyWith =>
          __$$PartnerSettingsStateImplCopyWithImpl<_$PartnerSettingsStateImpl>(
              this, _$identity);
}

abstract class _PartnerSettingsState implements PartnerSettingsState {
  const factory _PartnerSettingsState(
      {final String fullName,
      final String email,
      final String? bio,
      final String? phone,
      final String? state,
      final String category,
      final String? specialty,
      final String? location,
      final bool notificationsEnabled,
      final bool isActive,
      final String bookingSystemType,
      final String confirmationMode,
      final int dailyBookingLimit,
      final Map<String, List<String>> workingHours,
      final List<DateTime> closedDays,
      final bool isSaving,
      final bool isLoading,
      final String? errorMessage}) = _$PartnerSettingsStateImpl;

  @override
  String get fullName;
  @override
  String get email;
  @override
  String? get bio;
  @override // NEW: Bio field
  String? get phone;
  @override // From users table
  String? get state;
  @override // From users table (wilaya/state)
  String get category;
  @override
  String? get specialty;
  @override
  String? get location;
  @override
  bool get notificationsEnabled;
  @override
  bool get isActive;
  @override
  String get bookingSystemType;
  @override
  String get confirmationMode;
  @override
  int get dailyBookingLimit;
  @override
  Map<String, List<String>> get workingHours;
  @override
  List<DateTime> get closedDays;
  @override
  bool get isSaving;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$PartnerSettingsStateImplCopyWith<_$PartnerSettingsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
