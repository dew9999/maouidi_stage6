// lib/partner_dashboard_page/components/appointment_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

import '../../backend/supabase/supabase.dart';
import '../../features/appointments/presentation/partner_dashboard_controller.dart';
import '../components/dashboard_helpers.dart';
import '../components/homecare_details_view.dart';

/// Card displaying appointment information with action buttons
class AppointmentInfoCard extends ConsumerWidget {
  const AppointmentInfoCard({
    super.key,
    required this.appointment,
    required this.partnerId,
  });

  final dynamic appointment;
  final String partnerId;

  Color getStatusColor(BuildContext context, String? status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'Confirmed':
      case 'In Progress':
      case 'Completed':
        return theme.colorScheme.tertiary;
      case 'Cancelled_ByUser':
      case 'Cancelled_ByPartner':
      case 'NoShow':
        return theme.colorScheme.error;
      case 'Pending':
      case 'Rescheduled':
        return Colors.orange;
      default:
        return theme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final status = appointment.status;
    final appointmentId = appointment.id;
    final appointmentTime = appointment.appointmentTime.toLocal();
    final (displayName, displayPhone) = getPatientDisplayInfo({
      'on_behalf_of_patient_name': appointment.onBehalfOfPatientName,
      'patient_first_name': appointment.patientFirstName,
      'patient_last_name': appointment.patientLastName,
      'patient_phone': appointment.patientPhone,
      'on_behalf_of_patient_phone': appointment.onBehalfOfPatientPhone,
    });

    return Card(
      elevation: 2,
      shadowColor: theme.colorScheme.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 6, color: getStatusColor(context, status)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(appointmentTime),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(displayName, style: theme.textTheme.titleMedium),
                    Text(
                      displayPhone,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    HomecareDetailsView(
                      appointmentData: {
                        'case_description': appointment.caseDescription,
                        'patient_location': appointment.patientLocation,
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildActionButtons(context, ref, status, appointmentId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    String status,
    int appointmentId,
  ) {
    final theme = Theme.of(context);
    final controller =
        ref.read(partnerDashboardControllerProvider(partnerId).notifier);

    if (status == 'Pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () async {
              await controller.cancelAppointment(
                appointmentId,
                'Declined by partner',
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.outlineVariant),
              elevation: 0,
            ),
            child: const Text('Decline'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              await controller.confirmAppointment(appointmentId);
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 36),
              backgroundColor: theme.colorScheme.tertiary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirm'),
          ),
        ],
      );
    }

    if (status == 'Confirmed' || status == 'In Progress') {
      return Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: () async {
                await controller.completeAppointment(appointmentId);
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                textStyle: theme.textTheme.titleSmall,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline),
                  const SizedBox(width: 8),
                  Text(AppLocalizations.of(context)!.markcomp),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) async {
              if (value == 'no-show') {
                await controller.noShow(appointmentId);
              } else if (value == 'cancel') {
                final confirmed = await showStyledConfirmationDialog(
                  context: context,
                  title: AppLocalizations.of(context)!.cnclaptq,
                  content: 'Are you sure you want to cancel this appointment?',
                  confirmText: 'Confirm',
                );
                if (confirmed) {
                  await controller.cancelAppointment(
                    appointmentId,
                    'Canceled by partner',
                  );
                }
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'no-show',
                child: Text('Mark as No-Show'),
              ),
              const PopupMenuItem<String>(
                value: 'cancel',
                child: Text('Cancel Appointment'),
              ),
            ],
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

/// Card for upcoming appointments in the queue
class UpNextQueueCard extends ConsumerWidget {
  const UpNextQueueCard({
    super.key,
    required this.appointment,
    required this.partnerId,
  });

  final dynamic appointment;
  final String partnerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appointmentId = appointment.id;
    final (displayName, _) = getPatientDisplayInfo({
      'on_behalf_of_patient_name': appointment.onBehalfOfPatientName,
      'patient_first_name': appointment.patientFirstName,
      'patient_last_name': appointment.patientLastName,
      'patient_phone': appointment.patientPhone,
      'on_behalf_of_patient_phone': appointment.onBehalfOfPatientPhone,
    });
    final appointmentNumber = appointment.appointmentNumber;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.tertiary.withAlpha(25),
                child: Text(
                  '$appointmentNumber',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: theme.colorScheme.primary),
                ),
              ),
              title: Text(displayName, style: theme.textTheme.titleMedium),
              trailing: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                onSelected: (value) async {
                  final controller = ref.read(
                    partnerDashboardControllerProvider(partnerId).notifier,
                  );

                  if (value == 'cancel') {
                    final confirmed = await showStyledConfirmationDialog(
                      context: context,
                      title: AppLocalizations.of(context)!.cnclaptq,
                      content: 'Are you sure you want to cancel this request?',
                      confirmText: 'Confirm',
                    );
                    if (confirmed) {
                      await controller.cancelAppointment(
                        appointmentId,
                        'Canceled by partner',
                      );
                    }
                  } else if (value == 'reschedule') {
                    try {
                      await Supabase.instance.client.rpc(
                        'reschedule_appointment_to_end_of_queue',
                        params: {
                          'appointment_id_arg': appointmentId,
                          'partner_id_arg': partnerId,
                        },
                      );
                      controller.refresh();
                    } catch (e) {
                      if (context.mounted) {
                        showErrorSnackbar(
                          context,
                          'Failed to reschedule: ${e.toString()}',
                        );
                      }
                    }
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'reschedule',
                    child: Text('Move to End of Queue'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'cancel',
                    child: Text('Cancel Appointment'),
                  ),
                ],
              ),
            ),
            HomecareDetailsView(
              appointmentData: {
                'case_description': appointment.caseDescription,
                'patient_location': appointment.patientLocation,
              },
            ),
          ],
        ),
      ),
    );
  }
}
