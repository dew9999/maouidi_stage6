// lib/partner_profile_page/partner_profile_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

class PartnerProfilePageWidget extends ConsumerWidget {
  const PartnerProfilePageWidget({
    super.key,
    required this.partnerId,
  });

  final String? partnerId;

  static String routeName = 'PartnerProfilePage';
  static String routePath = '/partnerProfilePage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final l10n = AppLocalizations.of(context)!;

    if (partnerId == null || partnerId!.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ptrerr)),
        body: Center(
          child: Text(l10n.ptridmissing),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(
          'Partner Profile',
          style:
              textTheme.headlineMedium?.copyWith(color: colorScheme.onPrimary),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        top: true,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.medical_services_outlined,
                  size: 100,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  'Partner Profile',
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'This page is under migration to the new architecture.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Partner ID: $partnerId',
                  style: textTheme.bodySmall
                      ?.copyWith(color: colorScheme.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
