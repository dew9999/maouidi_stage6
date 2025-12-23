// lib/partner_profile_page/partner_profile_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../flutter_flow/flutter_flow_theme.dart';
import '../../flutter_flow/flutter_flow_util.dart';

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
    final theme = FlutterFlowTheme.of(context);

    if (partnerId == null || partnerId!.isEmpty) {
      return Scaffold(
        appBar:
            AppBar(title: Text(FFLocalizations.of(context).getText('ptrerr'))),
        body: Center(
          child: Text(FFLocalizations.of(context).getText('ptridmissing')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Partner Profile',
          style: theme.headlineMedium.copyWith(color: Colors.white),
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
                  color: theme.secondaryText,
                ),
                const SizedBox(height: 24),
                Text(
                  'Partner Profile',
                  style: theme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'This page is under migration to the new architecture.',
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Partner ID: $partnerId',
                  style: theme.bodySmall.copyWith(color: theme.secondaryText),
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
