// lib/features/search/presentation/partner_search_controller.dart

import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/search_repository.dart';
import 'search_state.dart';

part 'partner_search_controller.g.dart';

/// Controller for Partner Search.
///
/// Named PartnerSearchController to avoid conflict with Flutter's SearchController.
/// Manages search query, filters, and debounced search execution.
@riverpod
class PartnerSearchController extends _$PartnerSearchController {
  Timer? _debounceTimer;

  @override
  SearchState build() {
    // Clean up timer when provider is disposed
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    return const SearchState();
  }

  /// Update the search query and trigger debounced search.
  void updateQuery(String query) {
    state = state.copyWith(query: query);
    _debouncedSearch();
  }

  /// Update the category filter and perform immediate search.
  void updateCategoryFilter(String? category) {
    state = state.copyWith(categoryFilter: category);
    performSearch();
  }

  /// Update the location filter and perform immediate search.
  void updateLocationFilter(String? location) {
    state = state.copyWith(locationFilter: location);
    performSearch();
  }

  /// Clear all filters and search query.
  void clearFilters() {
    state = const SearchState();
    performSearch();
  }

  /// Debounced search - waits 500ms after last keystroke.
  void _debouncedSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      performSearch();
    });
  }

  /// Perform the actual search with current query and filters.
  Future<void> performSearch() async {
    // Don't search if query is empty and no filters are set
    if (state.query.trim().isEmpty &&
        state.categoryFilter == null &&
        state.locationFilter == null) {
      state = state.copyWith(results: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final repository = ref.read(searchRepositoryProvider);
      final results = await repository.searchPartners(
        query: state.query.trim().isEmpty ? null : state.query.trim(),
        category: state.categoryFilter,
        location: state.locationFilter,
      );

      state = state.copyWith(
        results: results,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Initialize search with a specific query (e.g., from navigation params).
  void initializeWithQuery(String query) {
    state = state.copyWith(query: query);
    performSearch();
  }
}
