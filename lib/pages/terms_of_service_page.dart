// lib/pages/terms_of_service_page.dart

import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  static String routeName = 'TermsOfServicePage';
  static String routePath = '/termsOfService';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        title: Text('Terms of Service', style: textTheme.headlineSmall),
        elevation: 2,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Text(
          '''
Last updated: September 13, 2025

Please replace this placeholder text with your own Terms of Service.

1. Agreement to Terms
   By using our application, you agree to be bound by these Terms of Service...

2. User Accounts
   When you create an account with us, you must provide us with information that is accurate, complete, and current at all times...

3. Prohibited Uses
   You may use the application only for lawful purposes and in accordance with the Terms...

...
          ''',
        ),
      ),
    );
  }
}
