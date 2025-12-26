import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/ui/welcome_screen/welcome_screen_widget.dart';

Future<void> showSignOutDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return showDialog(
    context: context,
    builder: (alertDialogContext) {
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Sign Out', style: textTheme.titleLarge),
        content: Text(
          'Are you sure you want to sign out?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertDialogContext),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(alertDialogContext);
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go(WelcomeScreenWidget.routePath);
              }
            },
            child: Text(
              'Sign Out',
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      );
    },
  );
}

Future<void> showDeleteAccountDialog(BuildContext context) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  return showDialog(
    context: context,
    builder: (alertDialogContext) {
      return AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text('Delete Account', style: textTheme.titleLarge),
        content: Text(
          'This action is irreversible. Are you sure?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertDialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final user = Supabase.instance.client.auth.currentUser;
                if (user == null) return;

                final response =
                    await Supabase.instance.client.functions.invoke(
                  'delete-user',
                  headers: {
                    'Authorization': 'Bearer ${user.id}',
                  },
                );

                if (response.status != 200) {
                  throw Exception(
                    response.data['error'] ?? 'Failed to delete account',
                  );
                }

                await Supabase.instance.client.auth.signOut();

                if (alertDialogContext.mounted) {
                  Navigator.pop(alertDialogContext);
                  if (context.mounted) {
                    context.go('/welcomeScreen');
                  }
                }
              } catch (e) {
                Navigator.pop(alertDialogContext);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting account: ${e.toString()}'),
                    ),
                  );
                }
              }
            },
            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
          ),
        ],
      );
    },
  );
}
