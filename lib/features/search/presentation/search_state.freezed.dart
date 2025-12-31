// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SearchState {
  String get query => throw _privateConstructorUsedError;
  String? get categoryFilter => throw _privateConstructorUsedError;
  String? get locationFilter => throw _privateConstructorUsedError;
  String? get specialtyFilter =>
      throw _privateConstructorUsedError; // NEW: Filter by specialty
  double? get minPrice =>
      throw _privateConstructorUsedError; // NEW: Minimum price range
  double? get maxPrice =>
      throw _privateConstructorUsedError; // NEW: Maximum price range
  double? get minRating =>
      throw _privateConstructorUsedError; // NEW: Minimum rating filter (e.g., 4.0 for 4+ stars)
  String? get availabilityFilter =>
      throw _privateConstructorUsedError; // NEW: 'today', 'this_week', 'any'
  List<MedicalPartnersRow> get results => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $SearchStateCopyWith<SearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SearchStateCopyWith<$Res> {
  factory $SearchStateCopyWith(
          SearchState value, $Res Function(SearchState) then) =
      _$SearchStateCopyWithImpl<$Res, SearchState>;
  @useResult
  $Res call(
      {String query,
      String? categoryFilter,
      String? locationFilter,
      String? specialtyFilter,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      String? availabilityFilter,
      List<MedicalPartnersRow> results,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class _$SearchStateCopyWithImpl<$Res, $Val extends SearchState>
    implements $SearchStateCopyWith<$Res> {
  _$SearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? categoryFilter = freezed,
    Object? locationFilter = freezed,
    Object? specialtyFilter = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? availabilityFilter = freezed,
    Object? results = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_value.copyWith(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      categoryFilter: freezed == categoryFilter
          ? _value.categoryFilter
          : categoryFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      locationFilter: freezed == locationFilter
          ? _value.locationFilter
          : locationFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      specialtyFilter: freezed == specialtyFilter
          ? _value.specialtyFilter
          : specialtyFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      availabilityFilter: freezed == availabilityFilter
          ? _value.availabilityFilter
          : availabilityFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      results: null == results
          ? _value.results
          : results // ignore: cast_nullable_to_non_nullable
              as List<MedicalPartnersRow>,
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
abstract class _$$SearchStateImplCopyWith<$Res>
    implements $SearchStateCopyWith<$Res> {
  factory _$$SearchStateImplCopyWith(
          _$SearchStateImpl value, $Res Function(_$SearchStateImpl) then) =
      __$$SearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String query,
      String? categoryFilter,
      String? locationFilter,
      String? specialtyFilter,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      String? availabilityFilter,
      List<MedicalPartnersRow> results,
      bool isLoading,
      String? errorMessage});
}

/// @nodoc
class __$$SearchStateImplCopyWithImpl<$Res>
    extends _$SearchStateCopyWithImpl<$Res, _$SearchStateImpl>
    implements _$$SearchStateImplCopyWith<$Res> {
  __$$SearchStateImplCopyWithImpl(
      _$SearchStateImpl _value, $Res Function(_$SearchStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? categoryFilter = freezed,
    Object? locationFilter = freezed,
    Object? specialtyFilter = freezed,
    Object? minPrice = freezed,
    Object? maxPrice = freezed,
    Object? minRating = freezed,
    Object? availabilityFilter = freezed,
    Object? results = null,
    Object? isLoading = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_$SearchStateImpl(
      query: null == query
          ? _value.query
          : query // ignore: cast_nullable_to_non_nullable
              as String,
      categoryFilter: freezed == categoryFilter
          ? _value.categoryFilter
          : categoryFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      locationFilter: freezed == locationFilter
          ? _value.locationFilter
          : locationFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      specialtyFilter: freezed == specialtyFilter
          ? _value.specialtyFilter
          : specialtyFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      minPrice: freezed == minPrice
          ? _value.minPrice
          : minPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      maxPrice: freezed == maxPrice
          ? _value.maxPrice
          : maxPrice // ignore: cast_nullable_to_non_nullable
              as double?,
      minRating: freezed == minRating
          ? _value.minRating
          : minRating // ignore: cast_nullable_to_non_nullable
              as double?,
      availabilityFilter: freezed == availabilityFilter
          ? _value.availabilityFilter
          : availabilityFilter // ignore: cast_nullable_to_non_nullable
              as String?,
      results: null == results
          ? _value._results
          : results // ignore: cast_nullable_to_non_nullable
              as List<MedicalPartnersRow>,
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

class _$SearchStateImpl implements _SearchState {
  const _$SearchStateImpl(
      {this.query = '',
      this.categoryFilter,
      this.locationFilter,
      this.specialtyFilter,
      this.minPrice,
      this.maxPrice,
      this.minRating,
      this.availabilityFilter,
      final List<MedicalPartnersRow> results = const [],
      this.isLoading = false,
      this.errorMessage})
      : _results = results;

  @override
  @JsonKey()
  final String query;
  @override
  final String? categoryFilter;
  @override
  final String? locationFilter;
  @override
  final String? specialtyFilter;
// NEW: Filter by specialty
  @override
  final double? minPrice;
// NEW: Minimum price range
  @override
  final double? maxPrice;
// NEW: Maximum price range
  @override
  final double? minRating;
// NEW: Minimum rating filter (e.g., 4.0 for 4+ stars)
  @override
  final String? availabilityFilter;
// NEW: 'today', 'this_week', 'any'
  final List<MedicalPartnersRow> _results;
// NEW: 'today', 'this_week', 'any'
  @override
  @JsonKey()
  List<MedicalPartnersRow> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'SearchState(query: $query, categoryFilter: $categoryFilter, locationFilter: $locationFilter, specialtyFilter: $specialtyFilter, minPrice: $minPrice, maxPrice: $maxPrice, minRating: $minRating, availabilityFilter: $availabilityFilter, results: $results, isLoading: $isLoading, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SearchStateImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.categoryFilter, categoryFilter) ||
                other.categoryFilter == categoryFilter) &&
            (identical(other.locationFilter, locationFilter) ||
                other.locationFilter == locationFilter) &&
            (identical(other.specialtyFilter, specialtyFilter) ||
                other.specialtyFilter == specialtyFilter) &&
            (identical(other.minPrice, minPrice) ||
                other.minPrice == minPrice) &&
            (identical(other.maxPrice, maxPrice) ||
                other.maxPrice == maxPrice) &&
            (identical(other.minRating, minRating) ||
                other.minRating == minRating) &&
            (identical(other.availabilityFilter, availabilityFilter) ||
                other.availabilityFilter == availabilityFilter) &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      query,
      categoryFilter,
      locationFilter,
      specialtyFilter,
      minPrice,
      maxPrice,
      minRating,
      availabilityFilter,
      const DeepCollectionEquality().hash(_results),
      isLoading,
      errorMessage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      __$$SearchStateImplCopyWithImpl<_$SearchStateImpl>(this, _$identity);
}

abstract class _SearchState implements SearchState {
  const factory _SearchState(
      {final String query,
      final String? categoryFilter,
      final String? locationFilter,
      final String? specialtyFilter,
      final double? minPrice,
      final double? maxPrice,
      final double? minRating,
      final String? availabilityFilter,
      final List<MedicalPartnersRow> results,
      final bool isLoading,
      final String? errorMessage}) = _$SearchStateImpl;

  @override
  String get query;
  @override
  String? get categoryFilter;
  @override
  String? get locationFilter;
  @override
  String? get specialtyFilter;
  @override // NEW: Filter by specialty
  double? get minPrice;
  @override // NEW: Minimum price range
  double? get maxPrice;
  @override // NEW: Maximum price range
  double? get minRating;
  @override // NEW: Minimum rating filter (e.g., 4.0 for 4+ stars)
  String? get availabilityFilter;
  @override // NEW: 'today', 'this_week', 'any'
  List<MedicalPartnersRow> get results;
  @override
  bool get isLoading;
  @override
  String? get errorMessage;
  @override
  @JsonKey(ignore: true)
  _$$SearchStateImplCopyWith<_$SearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
