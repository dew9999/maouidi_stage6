// lib/partner_dashboard_page/partner_dashboard_page_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

import '../backend/supabase/supabase.dart';
import '../components/error_state_widget.dart';
import '../features/appointments/presentation/partner_dashboard_controller.dart';
import 'views/schedule_view.dart';
import 'views/analytics_view.dart';
import 'views/clinic_dashboard_view.dart';
import 'components/dashboard_helpers.dart';

enum DashboardView {
  schedule,
  analytics,
}

class PartnerDashboardPageWidget extends ConsumerWidget {
  const PartnerDashboardPageWidget({
    super.key,
    required this.partnerId,
  });

  final String partnerId;
  static String routeName = 'PartnerDashboardPage';
  static String routePath = '/partnerDashboardPage';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          AppLocalizations.of(context)!.yourdash,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Inter',
            color: Colors.white,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: Supabase.instance.client
              .from('medical_partners')
              .select('category, booking_system_type')
              .eq('id', partnerId)
              .maybeSingle(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return Center(
                child: Text(
                  AppLocalizations.of(context)!.loadptrfail,
                ),
              );
            }

            final partnerData = snapshot.data!;
            final String category = partnerData['category'] ?? 'Doctors';

            if (category == 'Clinics') {
              return ClinicDashboard(partnerId: partnerId);
            } else {
              return _StandardPartnerDashboardView(
                partnerId: partnerId,
                bookingSystemType:
                    partnerData['booking_system_type'] ?? 'time_based',
                category: category,
              );
            }
          },
        ),
      ),
    );
  }
}

class _StandardPartnerDashboardView extends ConsumerWidget {
  const _StandardPartnerDashboardView({
    required this.partnerId,
    required this.bookingSystemType,
    required this.category,
  });

  final String partnerId;
  final String bookingSystemType;
  final String category;

  void _showBookForPatientDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final caseController = TextEditingController();
    final locationController = TextEditingController();
    final bool isHomecare = category == 'Homecare';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        title: Text(
          AppLocalizations.of(context)!.bookforpatient,
          style: theme.textTheme.titleLarge,
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.ptfullname,
                  ),
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context)!.fieldreq
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.ptphone,
                  ),
                  validator: (v) => v!.isEmpty
                      ? AppLocalizations.of(context)!.fieldreq
                      : null,
                ),
                if (isHomecare) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: caseController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.casedesc,
                    ),
                    validator: (v) => v!.isEmpty
                        ? AppLocalizations.of(context)!.fieldreq
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Location',
                    ),
                    validator: (v) => v!.isEmpty
                        ? AppLocalizations.of(context)!.fieldreq
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await Supabase.instance.client.rpc(
                    'book_appointment',
                    params: {
                      'partner_id_arg': partnerId,
                      'appointment_time_arg':
                          DateTime.now().toUtc().toIso8601String(),
                      'on_behalf_of_name_arg': nameController.text,
                      'on_behalf_of_phone_arg': phoneController.text,
                      'is_partner_override': true,
                      'case_description_arg':
                          isHomecare ? caseController.text : null,
                      'patient_location_arg':
                          isHomecare ? locationController.text : null,
                    },
                  );
                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.apptcreated,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Trigger refresh via controller
                    ref
                        .read(
                          partnerDashboardControllerProvider(partnerId)
                              .notifier,
                        )
                        .refresh();
                  }
                } catch (e) {
                  if (context.mounted) {
                    showErrorSnackbar(
                      context,
                      'Booking failed: ${e.toString()}',
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,),
            child: Text(AppLocalizations.of(context)!.submitreq),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboardAsync =
        ref.watch(partnerDashboardControllerProvider(partnerId));

    return dashboardAsync.when(
      data: (dashboardState) {
        final selectedView = dashboardState.selectedView;

        return Scaffold(
          floatingActionButton: selectedView != 'schedule'
              ? null
              : FloatingActionButton(
                  onPressed: () async {
                    if (bookingSystemType == 'number_based') {
                      _showBookForPatientDialog(context, ref);
                    } else {
                      await context.pushNamed(
                        'BookingPage',
                        queryParameters: {
                          'partnerId': partnerId,
                          'isPartnerBooking': 'true',
                        },
                      );
                      ref
                          .read(
                            partnerDashboardControllerProvider(partnerId)
                                .notifier,
                          )
                          .refresh();
                    }
                  },
                  backgroundColor: theme.colorScheme.primary,
                  elevation: 8,
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'schedule',
                      label: Text(
                        AppLocalizations.of(context)!.schedule,
                      ),
                      icon: const Icon(Icons.calendar_month),
                    ),
                    ButtonSegment(
                      value: 'analytics',
                      label: Text(
                        AppLocalizations.of(context)!.analytics,
                      ),
                      icon: const Icon(Icons.bar_chart),
                    ),
                  ],
                  selected: {selectedView},
                  onSelectionChanged: (newSelection) {
                    ref
                        .read(
                          partnerDashboardControllerProvider(partnerId)
                              .notifier,
                        )
                        .setSelectedView(newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surfaceContainerHigh,
                    foregroundColor: theme.colorScheme.onSurface,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: theme.colorScheme.primary,
                  ),
                ),
              ),
              Expanded(
                child: selectedView == 'schedule'
                    ? ScheduleView(
                        partnerId: partnerId,
                        dashboardState: dashboardState,
                        bookingSystemType: bookingSystemType,
                      )
                    : AnalyticsView(partnerId: partnerId),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorStateWidget(
        message: 'Failed to load dashboard: ${error.toString()}',
        onRetry: () {
          ref
              .read(
                partnerDashboardControllerProvider(partnerId).notifier,
              )
              .refresh();
        },
      ),
    );
  }
}
