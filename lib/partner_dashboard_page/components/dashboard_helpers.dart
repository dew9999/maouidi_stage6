// lib/partner_dashboard_page/components/dashboard_helpers.dart

import 'package:flutter/material.dart';

// Helper function to consistently get patient display info
(String, String) getPatientDisplayInfo(Map<String, dynamic> appointmentData) {
  final onBehalfOfName =
      appointmentData['on_behalf_of_patient_name'] as String?;
  final onBehalfOfPhone =
      appointmentData['on_behalf_of_patient_phone'] as String?;

  final patientFirstName = appointmentData['patient_first_name'] as String?;
  final patientLastName = appointmentData['patient_last_name'] as String?;
  final patientPhone = appointmentData['patient_phone'] as String?;

  final bookingUserName =
      ('${patientFirstName ?? ''} ${patientLastName ?? ''}').trim();

  // Use 'on behalf of' info first for manually added patients.
  final displayName = onBehalfOfName ??
      (bookingUserName.isNotEmpty ? bookingUserName : 'A Patient');
  final displayPhone = onBehalfOfPhone ?? patientPhone ?? 'No phone provided';

  return (displayName, displayPhone);
}

// This function shows a styled confirmation dialog
Future<bool> showStyledConfirmationDialog({
  required BuildContext context,
  required String title,
  required String content,
  required String confirmText,
}) async {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  final textTheme = theme.textTheme;

  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(title, style: textTheme.titleLarge),
      content: Text(content, style: textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}

// Reusable function for user-friendly error messages
void showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}
