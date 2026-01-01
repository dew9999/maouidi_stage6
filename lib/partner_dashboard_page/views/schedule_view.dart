// lib/partner_dashboard_page/views/schedule_view.dart

import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maouidi/core/localization_helpers.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

import '../../components/empty_state_widget.dart';
import '../../features/appointments/data/appointment_model.dart';
import '../../features/appointments/data/appointment_repository.dart';
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
    final selectedDate = dashboardState.selectedDate ?? DateTime.now();

    // Filter appointments based on selected status and DATE
    final filteredAppointments = dashboardState.appointments.where((appt) {
      // Exclude queue-based appointments
      if (appt.appointmentNumber != null) return false;

      // 1. Filter by Status (strict, case-insensitive)
      List<String> targetStatuses;
      if (selectedStatus == 'Canceled') {
        targetStatuses = ['Cancelled_ByUser', 'Cancelled_ByPartner', 'NoShow'];
      } else if (selectedStatus == 'Confirmed') {
        // Show ONLY Confirmed (NOT Pending)
        targetStatuses = ['Confirmed', 'confirmed'];
      } else if (selectedStatus == 'Pending') {
        // Show Pending AND Negotiation statuses
        targetStatuses = [
          'Pending',
          'pending_user_approval',
          'pending_partner_approval',
          'pending_payment',
        ];
      } else {
        targetStatuses = [selectedStatus];
      }
      // Case-insensitive comparison
      if (!targetStatuses
          .any((status) => status.toLowerCase() == appt.status.toLowerCase())) {
        return false;
      }

      // 2. Filter by Date (Ignore time part)
      final apptDate = appt.appointmentTime.toLocal();
      return isSameDay(apptDate, selectedDate);
    }).toList();

    // Sort by appointment time
    filteredAppointments.sort(
      (AppointmentModel a, AppointmentModel b) =>
          a.appointmentTime.compareTo(b.appointmentTime),
    );

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(partnerDashboardControllerProvider(partnerId).notifier)
            .refresh();
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // CALENDAR WIDGET
          // DATE PICKER BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  ref
                      .read(
                        partnerDashboardControllerProvider(partnerId).notifier,
                      )
                      .setSelectedDate(picked);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.yMMMMd().format(selectedDate),
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
          ),

          // STATUS FILTER CHIPS
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Wrap(
                    spacing: 8.0,
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
                      final isSelected =
                          selectedStatus == statusInfo['dbValue'];
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
                              ? theme.colorScheme.onPrimary
                              : theme.colorScheme.onSurface,
                        ),
                        backgroundColor: theme.colorScheme.surfaceContainerHigh,
                        side:
                            BorderSide(color: theme.colorScheme.outlineVariant),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          if (filteredAppointments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: EmptyStateWidget(
                icon: Icons.calendar_view_day_rounded,
                title: AppLocalizations.of(context)!.noaptsfound,
                message:
                    'No appointments found for ${DateFormat.yMMMd().format(selectedDate)}',
              ),
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
      ),
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
    final selectedDate = dashboardState.selectedDate ?? DateTime.now();

    // Use the full appointments list, then filter by date locally
    // (Since 'todayAppointments' in state is hardcoded to actual today by the repo)
    // Actually, dashboardState.appointments contains ALL appointments.
    final allAppointments =
        dashboardState.appointments as List<AppointmentModel>;

    // Filter appointments for the SELECTED date
    final dailyAppointments = allAppointments.where((appt) {
      final matches = isSameDay(appt.appointmentTime.toLocal(), selectedDate);
      if (allAppointments.indexOf(appt) < 3) {}
      return matches;
    }).toList();

    final currentPatient = dashboardState.currentPatient;

    // For ACTIVE queue, filter out canceled/completed.
    // For HISTORY (completed), filtering is different.

    // Sort all appointments by number or time
    dailyAppointments.sort((a, b) {
      if (a.appointmentNumber != null && b.appointmentNumber != null) {
        return a.appointmentNumber!.compareTo(b.appointmentNumber!);
      }
      return a.appointmentTime.compareTo(b.appointmentTime);
    });

    final activeAppointments = dailyAppointments.where((appt) {
      return !['Cancelled_ByUser', 'Cancelled_ByPartner', 'Completed', 'NoShow']
          .contains(appt.status);
    }).toList();

    final completedAppointments = dailyAppointments.where((appt) {
      return appt.status == 'Completed';
    }).toList();

    // Sorting is done above now.

    final upNextAppointments = activeAppointments
        .where(
          (a) =>
              a.status == 'Pending' ||
              a.status == 'Confirmed' ||
              a.status == 'confirmed' || // Fix for lowercase status
              a.status == 'pending' || // Fix for lowercase status
              a.status == 'pending_user_approval' ||
              a.status == 'pending_payment' ||
              a.status == 'pending_partner_approval',
        )
        .toList();

    final isToday = isSameDay(selectedDate, DateTime.now());

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(partnerDashboardControllerProvider(partnerId).notifier)
            .refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // CALENDAR WIDGET (Week View)

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    ref
                        .read(
                          partnerDashboardControllerProvider(partnerId)
                              .notifier,
                        )
                        .setSelectedDate(picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat.yMMMMd().format(selectedDate),
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
            ),
            // Active Appointments Section
            if (activeAppointments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: isToday
                      ? AppLocalizations.of(context)!.qready
                      : 'No Queue',
                  message: isToday
                      ? 'There are no active appointments in the queue for today.'
                      : 'No active appointments scheduled for this date.',
                ),
              )
            else ...[
              // Call Next Patient Button (Only visible if viewing TODAY)
              if (isToday &&
                  upNextAppointments.isNotEmpty &&
                  currentPatient == null)
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
                      foregroundColor: theme.colorScheme.onPrimary,
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Current Patient (Only if viewing TODAY and there IS a current patient)
              if (isToday && currentPatient != null) ...[
                NowServingCard(
                  appointmentData: {
                    'id': currentPatient.id,
                    'appointment_number': currentPatient.appointmentNumber,
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
                  onAction: () async {
                    await ref
                        .read(
                          partnerDashboardControllerProvider(partnerId)
                              .notifier,
                        )
                        .refresh();
                  },
                ),
                const SizedBox(height: 12),
                // Push to Back button
                OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await ref
                          .read(appointmentRepositoryProvider)
                          .pushPatientToBack(
                            currentPatient.id,
                            partnerId,
                          );
                      await ref
                          .read(
                            partnerDashboardControllerProvider(partnerId)
                                .notifier,
                          )
                          .refresh();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Patient moved to back of queue',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Failed to move patient: ${e.toString()}',
                            ),
                            backgroundColor: theme.colorScheme.error,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.arrow_downward,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(
                    'Push to Back of Queue',
                    style: TextStyle(color: theme.colorScheme.primary),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    side: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ],

              // Queue List
              if (upNextAppointments.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(
                    top: (isToday && currentPatient != null) ? 24 : 8,
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
                        isToday ? 'In Queue' : 'Appointments',
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
            // Completed Appointments Section
            if (completedAppointments.isNotEmpty) ...[
              const Divider(),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.history, color: theme.colorScheme.secondary),
                    const SizedBox(width: 8),
                    Text(
                      'Completed (${completedAppointments.length})',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              ...completedAppointments.map(
                (appt) => Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: AppointmentInfoCard(
                    appointment: appt,
                    partnerId: partnerId,
                  ),
                ),
              ),
              const SizedBox(height: 80), // Bottom padding
            ],
          ], // Close children array (Column)
        ), // Close SingleChildScrollView
      ), // Close RefreshIndicator
    );
  }
}
