// lib/search/search_results_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maouidi/components/partner_card_widget.dart';
import 'package:maouidi/components/empty_state_widget.dart';
import 'package:maouidi/flutter_flow/flutter_flow_theme.dart';
import 'package:maouidi/flutter_flow/flutter_flow_util.dart';
import 'package:maouidi/features/search/presentation/partner_search_controller.dart';
import 'package:maouidi/features/search/presentation/search_state.dart';

class SearchResultsPage extends ConsumerStatefulWidget {
  const SearchResultsPage({
    super.key,
    required this.searchTerm,
  });

  final String searchTerm;

  static String routeName = 'SearchResultsPage';
  static String routePath = '/searchResults';

  @override
  ConsumerState<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends ConsumerState<SearchResultsPage> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchTerm);

    // Initialize search with the provided search term
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(partnerSearchControllerProvider.notifier)
          .initializeWithQuery(widget.searchTerm);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final searchState = ref.watch(partnerSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.primaryBackground,
        iconTheme: IconThemeData(color: theme.primaryText),
        title: Text(
          FFLocalizations.of(context).getText('srchptr'),
          style: theme.headlineSmall,
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextFormField(
              controller: _searchController,
              onChanged: (value) {
                ref
                    .read(partnerSearchControllerProvider.notifier)
                    .updateQuery(value.trim());
              },
              decoration: InputDecoration(
                hintText: FFLocalizations.of(context).getText('refinesrch'),
                prefixIcon: Icon(Icons.search, color: theme.secondaryText),
                suffixIcon: searchState.query.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: theme.secondaryText),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(partnerSearchControllerProvider.notifier)
                              .updateQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: theme.secondaryBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Optional: Add filter chips here (category, location)
          if (searchState.categoryFilter != null ||
              searchState.locationFilter != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 8,
                children: [
                  if (searchState.categoryFilter != null)
                    FilterChip(
                      label: Text(searchState.categoryFilter!),
                      onDeleted: () {
                        ref
                            .read(partnerSearchControllerProvider.notifier)
                            .updateCategoryFilter(null);
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onSelected: (bool selected) {},
                    ),
                  if (searchState.locationFilter != null)
                    FilterChip(
                      label: Text(searchState.locationFilter!),
                      onDeleted: () {
                        ref
                            .read(partnerSearchControllerProvider.notifier)
                            .updateLocationFilter(null);
                      },
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onSelected: (bool selected) {},
                    ),
                ],
              ),
            ),

          Expanded(
            child: _buildSearchResults(searchState, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(SearchState searchState, FlutterFlowTheme theme) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(
              'Error: ${searchState.errorMessage}',
              style: theme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: FFLocalizations.of(context).getText('noresults'),
        message: FFLocalizations.of(context).getText('noresultsmsg'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        return PartnerCardWidget(partner: searchState.results[index]);
      },
    );
  }
}
