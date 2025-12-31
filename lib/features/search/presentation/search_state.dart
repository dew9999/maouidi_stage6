// lib/features/search/presentation/search_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../backend/supabase/supabase.dart';

part 'search_state.freezed.dart';

/// State for the Partner Search feature.
///
/// Manages search query, filters, results, and loading state.
@freezed
class SearchState with _$SearchState {
  const factory SearchState({
    @Default('') String query,
    String? categoryFilter,
    String? locationFilter,
    String? specialtyFilter, // NEW: Filter by specialty
    double? minPrice, // NEW: Minimum price range
    double? maxPrice, // NEW: Maximum price range
    double? minRating, // NEW: Minimum rating filter (e.g., 4.0 for 4+ stars)
    String? availabilityFilter, // NEW: 'today', 'this_week', 'any'
    @Default([]) List<MedicalPartnersRow> results,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchState;
}
