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
    @Default([]) List<MedicalPartnersRow> results,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _SearchState;
}
