// lib/partner_list_page/partner_list_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import 'package:maouidi/components/partner_card_widget.dart';
import 'package:maouidi/features/partners/presentation/partner_providers.dart';

class PartnerListPageWidget extends ConsumerWidget {
  const PartnerListPageWidget({
    super.key,
    this.categoryName,
  });

  final String? categoryName;

  static String routeName = 'PartnerListPage';
  static String routePath = '/partnerListPage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    // Watch the partner list provider with current filter parameters
    final partnersAsync = ref.watch(
      partnerListProvider(
        PartnerListParams(
          category: categoryName ?? 'Doctors',
          state: null,
          specialty: null,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text(
          categoryName ?? l10n.ptrlist,
          style: textTheme.headlineSmall,
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: partnersAsync.when(
        data: (partners) {
          if (partners.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  l10n.nopartners,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
            itemCount: partners.length,
            itemBuilder: (context, index) {
              final partner = partners[index];
              return PartnerCardWidget(partner: partner);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load partners. Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ),
          );
        },
      ),
    );
  }
}
