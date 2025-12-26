// lib/pages/privacy_policy_page.dart

import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static String routeName = 'PrivacyPolicyPage';
  static String routePath = '/privacyPolicy';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text('Privacy Policy', style: textTheme.headlineSmall),
        elevation: 2,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Last updated: September 13, 2025

Please replace this placeholder text with your own Privacy Policy.

1. Introduction
   Welcome to Maouidi. We are committed to protecting your personal information and your right to privacy...

2. Information We Collect
   We may collect personal information that you voluntarily provide to us when you register on the application...

3. How We Use Your Information
   We use personal information collected via our application for a variety of business purposes described below...

...
          ''',
        ),
      ),
    );
  }
}
