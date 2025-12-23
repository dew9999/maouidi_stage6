import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/ui/welcome_screen/welcome_screen_widget.dart';

Future<void> showSignOutDialog(BuildContext context) async {
  final theme = FlutterFlowTheme.of(context);

  return showDialog(
    context: context,
    builder: (alertDialogContext) {
      return AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Sign Out', style: theme.titleLarge),
        content: Text(
          'Are you sure you want to sign out?',
          style: theme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertDialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(alertDialogContext); // Close dialog

              // FIX: Use Supabase directly
              await Supabase.instance.client.auth.signOut();

              if (context.mounted) {
                context.go(WelcomeScreenWidget.routePath);
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: theme.error),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showDeleteAccountDialog(BuildContext context) async {
  final theme = FlutterFlowTheme.of(context);

  return showDialog(
    context: context,
    builder: (alertDialogContext) {
      return AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text('Delete Account', style: theme.titleLarge),
        content: Text(
          'This action is irreversible. Are you sure?',
          style: theme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertDialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Add delete logic here
              Navigator.pop(alertDialogContext);
            },
            child: Text('Delete', style: TextStyle(color: theme.error)),
          ),
        ],
      );
    },
  );
}
