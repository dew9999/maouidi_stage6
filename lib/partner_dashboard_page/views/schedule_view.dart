// lib/partner_dashboard_page/views/schedule_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maouidi/core/localization_helpers.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

import '../../components/empty_state_widget.dart';
import '../../features/appointments/presentation/partner_dashboard_controller.dart';
import '../components/now_serving_card.dart';
import '../components/appointment_card.dart';

/// Main schedule viewthat delegates to either time-based or queue-based view
class ScheduleView extends ConsumerWidget {
  const ScheduleView({
    super.key,
    required this.partnerId,
    required this.dashboardState,
    required this.bookingSystemType,
  });

  final String partnerId;
  final dynamic dashboardState;
  final String bookingSystemType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookingSystemType == 'number_based') {
      return NumberQueueView(
        partnerId: partnerId,
        dashboardState: dashboardState,
      );
    } else {
      return TimeSlotView(
        partnerId: partnerId,
        dashboardState: dashboardState,
      );
    }
  }
}

/// Time-based appointment view (for doctors/clinics with specific time slots)
class TimeSlotView extends ConsumerWidget {
  const TimeSlotView({
    super.key,
    required this.partnerId,
    required this.dashboardState,
  });

  final String partnerId;
  final dynamic dashboardState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selectedStatus = dashboardState.selectedStatus;

    // Filter appointments based on selected status
    final filteredAppointments = dashboardState.appointments.where((appt) {
      // Exclude queue-based appointments
      if (appt.appointmentNumber != null) return false;

      List<String> targetStatuses;
      if (selectedStatus == 'Canceled') {
        targetStatuses = ['Cancelled_ByUser', 'Cancelled_ByPartner', 'NoShow'];
      } else {
        targetStatuses = [selectedStatus];
      }

      return targetStatuses.contains(appt.status);
    }).toList();

    // Sort by appointment time
    filteredAppointments
        .sort((a, b) => a.appointmentTime.compareTo(b.appointmentTime));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  {
                    'dbValue': 'Pending',
                    'display': getLocalizedStatus(context, 'Pending'),
                  },
                  {
                    'dbValue': 'Confirmed',
                    'display': getLocalizedStatus(context, 'Confirmed'),
                  },
                  {
                    'dbValue': 'Completed',
                    'display': getLocalizedStatus(context, 'Completed'),
                  },
                  {
                    'dbValue': 'Canceled',
                    'display': AppLocalizations.of(context)!.canceled,
                  },
                ].map((statusInfo) {
                  final isSelected = selectedStatus == statusInfo['dbValue'];
                  return ChoiceChip(
                    label: Text(statusInfo['display']!),
                    selected: isSelected,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        ref
                            .read(
                              partnerDashboardControllerProvider(partnerId)
                                  .notifier,
                            )
                            .setSelectedStatus(statusInfo['dbValue']!);
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    side: BorderSide(color: theme.colorScheme.outlineVariant),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        if (filteredAppointments.isEmpty)
          EmptyStateWidget(
            icon: Icons.calendar_view_day_rounded,
            title: AppLocalizations.of(context)!.noaptsfound,
            message: AppLocalizations.of(context)!.noaptsfltr,
          )
        else
          ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            primary: false,
            shrinkWrap: true,
            itemCount: filteredAppointments.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AppointmentInfoCard(
                  appointment: filteredAppointments[index],
                  partnerId: partnerId,
                ),
              );
            },
          ),
      ],
    );
  }
}

/// Queue-based appointment view (for clinics with number system)
class NumberQueueView extends ConsumerWidget {
  const NumberQueueView({
    super.key,
    required this.partnerId,
    required this.dashboardState,
  });

  final String partnerId;
  final dynamic dashboardState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final todayAppointments = dashboardState.todayAppointments;
    final currentPatient = dashboardState.currentPatient;

    // Filter to active appointments (not canceled or completed)
    final activeAppointments = todayAppointments.where((appt) {
      return !['Cancelled_ByUser', 'Cancelled_ByPartner', 'Completed', 'NoShow']
          .contains(appt.status);
    }).toList();

    final upNextAppointments =
        activeAppointments.where((a) => a.status == 'Pending').toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: theme.colorScheme.outlineVariant, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: theme.textTheme.titleMedium,
                ),
                Icon(
                  Icons.calendar_month_outlined,
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: activeAppointments.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: AppLocalizations.of(context)!.qready,
                  message:
                      'There are no active appointments in the queue for today.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  children: [
                    // Call Next Patient Button
                    if (upNextAppointments.isNotEmpty && currentPatient == null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FilledButton.icon(
                          onPressed: () async {
                            await ref
                                .read(
                                  partnerDashboardControllerProvider(partnerId)
                                      .notifier,
                                )
                                .nextPatient();
                          },
                          icon: const Icon(Icons.person_add, size: 24),
                          label: const Text('Call Next Patient'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 56),
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (currentPatient != null)
                      NowServingCard(
                        appointmentData: {
                          'id': currentPatient.id,
                          'appointment_number':
                              currentPatient.appointmentNumber,
                          'on_behalf_of_patient_name':
                              currentPatient.onBehalfOfPatientName,
                          'patient_first_name': currentPatient.patientFirstName,
                          'patient_last_name': currentPatient.patientLastName,
                          'patient_phone': currentPatient.patientPhone,
                          'on_behalf_of_patient_phone':
                              currentPatient.onBehalfOfPatientPhone,
                          'case_description': currentPatient.caseDescription,
                          'patient_location': currentPatient.patientLocation,
                          'status': currentPatient.status,
                        },
                        onAction: () {
                          ref
                              .read(
                                partnerDashboardControllerProvider(partnerId)
                                    .notifier,
                              )
                              .refresh();
                        },
                      ),
                    if (upNextAppointments.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          top: currentPatient != null ? 24 : 8,
                          bottom: 8,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'In Queue',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${upNextAppointments.length}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...upNextAppointments.map(
                        (appt) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: AppointmentInfoCard(
                            appointment: appt,
                            partnerId: partnerId,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}
