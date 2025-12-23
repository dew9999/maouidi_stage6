// lib/ui/user_profile/user_profile_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserProfileWidget extends ConsumerWidget {
  const UserProfileWidget({super.key});

  static String routeName = 'user_profile';
  static String routePath = '/userProfile';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          FFLocalizations.of(context).getText('yourprof'),
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
                  Icons.person_outline,
                  size: 100,
                  color: theme.secondaryText,
                ),
                const SizedBox(height: 24),
                Text(
                  'User Profile',
                  style: theme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  'This page is under migration to the new architecture.',
                  style: theme.bodyMedium.copyWith(color: theme.secondaryText),
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
