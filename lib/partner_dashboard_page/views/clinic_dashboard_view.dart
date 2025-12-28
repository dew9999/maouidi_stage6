// lib/partner_dashboard_page/views/clinic_dashboard_view.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

import '../../backend/supabase/supabase.dart';
import '../../components/empty_state_widget.dart';
import '../../components/error_state_widget.dart';
import '../../core/localization_helpers.dart';
import '../../features/appointments/presentation/clinic_dashboard_controller.dart';
import 'analytics_view.dart';

/// Main clinic dashboard widget (for multi-doctor clinics)
class ClinicDashboard extends ConsumerWidget {
  const ClinicDashboard({super.key, required this.partnerId});

  final String partnerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateAsync = ref.watch(clinicDashboardControllerProvider(partnerId));

    return stateAsync.when(
      data: (state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SegmentedButton<ClinicDashboardView>(
                segments: [
                  ButtonSegment(
                    value: ClinicDashboardView.schedule,
                    label: Text(AppLocalizations.of(context)!.allapts),
                    icon: const Icon(Icons.calendar_month),
                  ),
                  ButtonSegment(
                    value: ClinicDashboardView.analytics,
                    label: Text(
                      AppLocalizations.of(context)!.clncanalytics,
                    ),
                    icon: const Icon(Icons.bar_chart),
                  ),
                ],
                selected: {state.currentView},
                onSelectionChanged: (newSelection) {
                  ref
                      .read(
                        clinicDashboardControllerProvider(partnerId).notifier,
                      )
                      .setView(newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHigh,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor:
                      Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Expanded(
              child: state.currentView == ClinicDashboardView.schedule
                  ? ClinicScheduleView(clinicId: partnerId, state: state)
                  : ClinicAnalyticsView(clinicId: partnerId),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => ErrorStateWidget(
        message: 'Failed to load clinic dashboard: ${err.toString()}',
        onRetry: () =>
            ref.refresh(clinicDashboardControllerProvider(partnerId)),
      ),
    );
  }
}

/// Schedule view for clinic showing all doctors' appointments
class ClinicScheduleView extends ConsumerWidget {
  const ClinicScheduleView({
    super.key,
    required this.clinicId,
    required this.state,
  });

  final String clinicId;
  final ClinicDashboardState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final doctors = state.doctors;
    final selectedDoctorId = state.selectedDoctorId;
    final selectedDate = state.selectedDate;
    final isLoading = state.isLoading;

    // Filter appointments client-side by selectedDate if provided
    final filteredAppointments = selectedDate != null
        ? state.appointments.where((appt) {
            final apptTime =
                DateTime.parse(appt['appointment_time'] as String).toLocal();
            return apptTime.year == selectedDate.year &&
                apptTime.month == selectedDate.month &&
                apptTime.day == selectedDate.day;
          }).toList()
        : state.appointments;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              // Doctor filter dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedDoctorId,
                  hint: Text(AppLocalizations.of(context)!.fltrdoc),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  items: [
                    DropdownMenuItem<String>(
                      value: null,
                      child: Text(AppLocalizations.of(context)!.alldocs),
                    ),
                    ...doctors.map(
                      (doc) => DropdownMenuItem<String>(
                        value: doc.id,
                        child: Text(doc.fullName ?? 'Unnamed Doctor'),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    ref
                        .read(
                          clinicDashboardControllerProvider(clinicId).notifier,
                        )
                        .setSelectedDoctor(value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Date picker button
              OutlinedButton.icon(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    ref
                        .read(
                          clinicDashboardControllerProvider(clinicId).notifier,
                        )
                        .setSelectedDate(pickedDate);
                  }
                },
                icon: Icon(
                  Icons.calendar_today,
                  color:
                      selectedDate != null ? theme.colorScheme.primary : null,
                ),
                label: Text(
                  selectedDate != null
                      ? DateFormat.MMMd().format(selectedDate)
                      : 'All Dates',
                  style: TextStyle(
                    color:
                        selectedDate != null ? theme.colorScheme.primary : null,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  side: BorderSide(
                    color: selectedDate != null
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outlineVariant,
                  ),
                ),
              ),
              if (selectedDate != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    ref
                        .read(
                          clinicDashboardControllerProvider(clinicId).notifier,
                        )
                        .setSelectedDate(null);
                  },
                  tooltip: 'Clear date filter',
                ),
              ],
            ],
          ),
        ),
        if (isLoading) const LinearProgressIndicator(),
        Expanded(
          child: filteredAppointments.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.calendar_today_rounded,
                  title: AppLocalizations.of(context)!.noaptsfound,
                  message: AppLocalizations.of(context)!.noaptsfltr,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    final appt = filteredAppointments[index];
                    final time =
                        DateTime.parse(appt['appointment_time'] as String)
                            .toLocal();
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          appt['patient_name'] as String? ?? 'A Patient',
                          style: theme.textTheme.titleMedium,
                        ),
                        subtitle: Text(
                          'With: ${appt['doctor_name'] as String? ?? 'N/A'}\nStatus: ${getLocalizedStatus(context, appt['status'] as String)}',
                          style: theme.textTheme.bodySmall,
                        ),
                        isThreeLine: true,
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat.yMMMd().format(time),
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              DateFormat.jm().format(time),
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Analytics view for clinic showing aggregate statistics
class ClinicAnalyticsView extends ConsumerWidget {
  const ClinicAnalyticsView({super.key, required this.clinicId});

  final String clinicId;

  Future<Map<String, dynamic>> _fetchAnalytics({String? doctorId}) async {
    final response = await Supabase.instance.client.rpc(
      'get_clinic_analytics',
      params: {
        'clinic_id_arg': clinicId,
        if (doctorId != null) 'doctor_id_arg': doctorId,
      },
    );

    return response as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final clinicState =
        ref.watch(clinicDashboardControllerProvider(clinicId)).value;
    final selectedDoctorId = clinicState?.selectedDoctorId;
    final doctors = clinicState?.doctors ?? [];

    return Column(
      children: [
        // Doctor Filter Dropdown
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: DropdownButtonFormField<String>(
            value: selectedDoctorId,
            hint: Text(AppLocalizations.of(context)!.fltrdoc),
            decoration: InputDecoration(
              labelText: 'Analytics Filter',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.people, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'All Doctors (Combined)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              ...doctors.map(
                (doc) => DropdownMenuItem<String>(
                  value: doc.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(doc.fullName ?? 'Unnamed Doctor'),
                    ],
                  ),
                ),
              ),
            ],
            onChanged: (value) {
              ref
                  .read(clinicDashboardControllerProvider(clinicId).notifier)
                  .setSelectedDoctor(value);
            },
          ),
        ),
        // Info message
        if (selectedDoctorId == null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Showing combined statistics for all doctors. Select a doctor to view individual stats.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: theme.colorScheme.secondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Viewing analytics for: ${doctors.firstWhere(
                            (d) => d.id == selectedDoctorId,
                            orElse: () => MedicalPartnersRow({
                              'id': '',
                              'full_name': 'Selected Doctor',
                            }),
                          ).fullName ?? 'Selected Doctor'}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        // Analytics Display
        Expanded(
          child: FutureBuilder<Map<String, dynamic>>(
            key: ValueKey('analytics_$selectedDoctorId'),
            future: _fetchAnalytics(doctorId: selectedDoctorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData) {
                return ErrorStateWidget(
                  message: AppLocalizations.of(context)!.loadanalyticsfail,
                  onRetry: () => (context as Element).markNeedsBuild(),
                );
              }

              final data = snapshot.data!;
              final summary = data['summary'] as Map<String, dynamic>;
              final weekly = List<Map<String, dynamic>>.from(
                data['weekly'] as List? ?? [],
              );

              // Extract stats, excluding Pending
              final totalAppointments = (summary['total'] as int? ?? 0) -
                  (summary['pending'] as int? ?? 0);
              final completedCount = summary['completed'] as int? ?? 0;
              final confirmedCount = summary['confirmed'] as int? ?? 0;
              final canceledCount =
                  (summary['cancelled_by_user'] as int? ?? 0) +
                      (summary['cancelled_by_partner'] as int? ?? 0) +
                      (summary['no_show'] as int? ?? 0);

              return AnalyticsViewContent(
                summaryStats: {
                  'total': totalAppointments,
                  'completed': completedCount,
                  'confirmed': confirmedCount,
                  'canceled': canceledCount,
                  'week_completed': summary['week_completed'] as int? ?? 0,
                  'month_completed': summary['month_completed'] as int? ?? 0,
                },
                weeklyStats: weekly,
              );
            },
          ),
        ),
      ],
    );
  }
}
