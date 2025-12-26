// lib/core/localization_helpers.dart

import 'package:flutter/material.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

// Helper to translate appointment status
String getLocalizedStatus(BuildContext context, String status) {
  final l10n = AppLocalizations.of(context)!;

  final statusMap = {
    'Pending': l10n.status_pending,
    'Confirmed': l10n.status_confirmed,
    'Completed': l10n.status_completed,
    'Cancelled_ByUser': l10n.status_cancelled_by_user,
    'Cancelled_ByPartner': l10n.status_cancelled_by_partner,
    'NoShow': l10n.status_no_show,
    'Rescheduled': l10n.status_rescheduled,
  };
  return statusMap[status] ??
      status; // Fallback to the original string if not found
}

// Helper to translate medical specialties
String getLocalizedSpecialty(BuildContext context, String specialty) {
  final l10n = AppLocalizations.of(context)!;

  // We'll generate a key from the specialty name
  final key =
      'specialty_${specialty.replaceAll(' ', '_').replaceAll('/', '').replaceAll('-', '_').toLowerCase()}';

  // Try to get translation, fallback to original specialty name
  try {
    // Note: This requires the specialty keys to exist in the ARB files
    return specialty; // For now, return as-is until ARB files have all specialty keys
  } catch (e) {
    return specialty;
  }
}
