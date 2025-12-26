// lib/search/search_results_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import 'package:maouidi/components/partner_card_widget.dart';
import 'package:maouidi/components/empty_state_widget.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;
    final searchState = ref.watch(partnerSearchControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          l10n.srchptr,
          style: textTheme.headlineSmall,
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
                hintText: l10n.refinesrch,
                prefixIcon:
                    Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                suffixIcon: searchState.query.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref
                              .read(partnerSearchControllerProvider.notifier)
                              .updateQuery('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surface,
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
            child: _buildSearchResults(
              searchState,
              theme,
              textTheme,
              colorScheme,
              l10n,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(
    SearchState searchState,
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
    AppLocalizations l10n,
  ) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Error: ${searchState.errorMessage}',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.search_off_rounded,
        title: l10n.noresults,
        message: l10n.noresultsmsg,
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
