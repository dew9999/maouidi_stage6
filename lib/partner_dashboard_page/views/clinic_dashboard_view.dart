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
                          clinicDashboardControllerProvider(partnerId).notifier,)
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
    final appointments = state.appointments;
    final doctors = state.doctors;
    final selectedDoctorId = state.selectedDoctorId;
    final isLoading = state.isLoading;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
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
                  .read(clinicDashboardControllerProvider(clinicId).notifier)
                  .setSelectedDoctor(value);
            },
          ),
        ),
        if (isLoading) const LinearProgressIndicator(),
        Expanded(
          child: appointments.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.calendar_today_rounded,
                  title: AppLocalizations.of(context)!.noaptsfound,
                  message: AppLocalizations.of(context)!.noaptsfltr,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
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
class ClinicAnalyticsView extends StatelessWidget {
  const ClinicAnalyticsView({super.key, required this.clinicId});

  final String clinicId;

  Future<Map<String, dynamic>> _fetchAnalytics() async {
    return await Supabase.instance.client.rpc(
      'get_clinic_analytics',
      params: {
        'clinic_id_arg': clinicId,
      },
    ).then((data) => data as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchAnalytics(),
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

        final summary = snapshot.data!['summary'] as Map<String, dynamic>;
        final weekly =
            List<Map<String, dynamic>>.from(snapshot.data!['weekly'] as List);

        return AnalyticsViewContent(
          summaryStats: {
            'total': summary['total'] as int? ?? 0,
            'week_completed': summary['week_completed'] as int? ?? 0,
            'month_completed': summary['month_completed'] as int? ?? 0,
            'partner_canceled': 0,
          },
          weeklyStats: weekly,
        );
      },
    );
  }
}
