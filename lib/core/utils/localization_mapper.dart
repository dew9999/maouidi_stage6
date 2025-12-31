import 'package:flutter/widgets.dart';
import '../../generated/l10n/app_localizations.dart';

class LocalizationMapper {
  static String getSpecialty(String dbValue, BuildContext context) {
    if (dbValue.isEmpty) return '';
    final key = dbValue.trim().toLowerCase();
    final l10n = AppLocalizations.of(context)!;

    switch (key) {
      case 'cardiology':
        return l10n.specialty_cardiology;
      case 'dentist':
        return l10n.specialty_dentist;
      case 'dermatology':
        return l10n.specialty_dermatology;
      case 'pediatrics':
        return l10n.specialty_pediatrics;
      case 'ophthalmology':
        return l10n.specialty_ophthalmology;
      case 'orthopedics':
        return l10n.specialty_orthopedics;
      case 'neurology':
        return l10n.specialty_neurology;
      case 'gynecology':
        return l10n.specialty_gynecology;
      case 'general practice':
        return l10n.specialty_general_practice;
      // Add more cases as needed based on database content
      default:
        return dbValue;
    }
  }

  static String getState(String dbValue, BuildContext context) {
    if (dbValue.isEmpty) return '';
    final key = dbValue.trim().toLowerCase();
    final l10n = AppLocalizations.of(context)!;

    switch (key) {
      case 'algiers':
      case 'alger':
        return l10n.state_algiers;
      case 'oran':
        return l10n.state_oran;
      case 'constantine':
        return l10n.state_constantine;
      case 'annaba':
        return l10n.state_annaba;
      case 'batna':
        return l10n.state_batna;
      case 'setif':
      case 'sétif':
        return l10n.state_setif;
      case 'blida':
        return l10n.state_blida;
      case 'tlemcen':
        return l10n.state_tlemcen;
      // Add more cases as needed
      default:
        return dbValue;
    }
  }

  static String getCategory(String dbValue, BuildContext context) {
    if (dbValue.isEmpty) return '';
    final key = dbValue.trim().toLowerCase();
    final l10n = AppLocalizations.of(context)!;

    switch (key) {
      case 'doctors':
        return l10n.doctors;
      case 'clinics':
        return l10n.clinics;
      case 'homecare':
        return l10n.homecare;
      case 'charities':
        return l10n.charities;
      default:
        return dbValue;
    }
  }

  static String getStatus(String dbValue, BuildContext context) {
    if (dbValue.isEmpty) return '';
    final key = dbValue.trim();
    final l10n = AppLocalizations.of(context)!;

    // Normalize commonly used statuses
    switch (key) {
      case 'Pending':
      case 'pending':
        return l10n.status_pending;
      case 'Confirmed':
      case 'confirmed':
        return l10n.status_confirmed;
      case 'Completed':
      case 'completed':
        return l10n.status_completed;
      case 'Cancelled':
      case 'cancelled':
      case 'Cancelled_ByUser':
      case 'Cancelled_ByPartner':
        return l10n
            .status_cancelled_by_partner; // Assuming generic cancel or specific
      case 'NoShow':
        return l10n.status_no_show;
      case 'In Progress':
      case 'in_progress':
        return l10n.status_in_progress;
      default:
        return dbValue.replaceAll('_', ' ');
    }
  }
}
