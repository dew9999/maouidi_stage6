// lib/partner_dashboard_page/partner_dashboard_page_widget.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:maouidi/core/localization_helpers.dart';
import '../components/empty_state_widget.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../flutter_flow/flutter_flow_util.dart';
import '../flutter_flow/flutter_flow_widgets.dart';
import '../backend/supabase/supabase.dart';
import 'components/homecare_details_view.dart';
import 'components/dashboard_helpers.dart';
import 'components/now_serving_card.dart';
import '../features/appointments/presentation/partner_dashboard_controller.dart';

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
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        title: Text(
          FFLocalizations.of(context).getText('yourdash'),
          style: theme.headlineMedium.override(
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
                  FFLocalizations.of(context).getText('loadptrfail'),
                ),
              );
            }

            final partnerData = snapshot.data!;
            final String category = partnerData['category'] ?? 'Doctors';

            if (category == 'Clinics') {
              return _ClinicDashboardView(partnerId: partnerId);
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
    final theme = FlutterFlowTheme.of(context);
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final caseController = TextEditingController();
    final locationController = TextEditingController();
    final bool isHomecare = category == 'Homecare';

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.secondaryBackground,
        title: Text(
          FFLocalizations.of(context).getText('bookforpatient'),
          style: theme.titleLarge,
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
                    labelText:
                        FFLocalizations.of(context).getText('ptfullname'),
                  ),
                  validator: (v) => v!.isEmpty
                      ? FFLocalizations.of(context).getText('fieldreq')
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: FFLocalizations.of(context).getText('ptphone'),
                  ),
                  validator: (v) => v!.isEmpty
                      ? FFLocalizations.of(context).getText('fieldreq')
                      : null,
                ),
                if (isHomecare) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: caseController,
                    decoration: InputDecoration(
                      labelText:
                          FFLocalizations.of(context).getText('casedesc'),
                    ),
                    validator: (v) => v!.isEmpty
                        ? FFLocalizations.of(context).getText('fieldreq')
                        : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Location',
                    ),
                    validator: (v) => v!.isEmpty
                        ? FFLocalizations.of(context).getText('fieldreq')
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
              FFLocalizations.of(context).getText('cancel'),
              style: TextStyle(color: theme.secondaryText),
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
                          FFLocalizations.of(context).getText('apptcreated'),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                    // Trigger refresh via controller
                    ref
                        .read(partnerDashboardControllerProvider(partnerId)
                            .notifier,)
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
            style: ElevatedButton.styleFrom(backgroundColor: theme.primary),
            child: Text(FFLocalizations.of(context).getText('submitreq')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
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
                          .read(partnerDashboardControllerProvider(partnerId)
                              .notifier,)
                          .refresh();
                    }
                  },
                  backgroundColor: theme.primary,
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
                        FFLocalizations.of(context).getText('schedule'),
                      ),
                      icon: const Icon(Icons.calendar_month),
                    ),
                    ButtonSegment(
                      value: 'analytics',
                      label: Text(
                        FFLocalizations.of(context).getText('analytics'),
                      ),
                      icon: const Icon(Icons.bar_chart),
                    ),
                  ],
                  selected: {selectedView},
                  onSelectionChanged: (newSelection) {
                    ref
                        .read(partnerDashboardControllerProvider(partnerId)
                            .notifier,)
                        .setSelectedView(newSelection.first);
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: theme.secondaryBackground,
                    foregroundColor: theme.primaryText,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: theme.primary,
                  ),
                ),
              ),
              Expanded(
                child: selectedView == 'schedule'
                    ? _ScheduleView(
                        partnerId: partnerId,
                        dashboardState: dashboardState,
                        bookingSystemType: bookingSystemType,
                      )
                    : _AnalyticsView(partnerId: partnerId),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Failed to load dashboard: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(
                        partnerDashboardControllerProvider(partnerId).notifier,)
                    .refresh();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleView extends ConsumerWidget {
  const _ScheduleView({
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
      return _NumberQueueView(
        partnerId: partnerId,
        dashboardState: dashboardState,
      );
    } else {
      return _TimeSlotView(
        partnerId: partnerId,
        dashboardState: dashboardState,
      );
    }
  }
}

class _TimeSlotView extends ConsumerWidget {
  const _TimeSlotView({
    required this.partnerId,
    required this.dashboardState,
  });

  final String partnerId;
  final dynamic dashboardState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
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
                    'display': FFLocalizations.of(context).getText('canceled'),
                  },
                ].map((statusInfo) {
                  final isSelected = selectedStatus == statusInfo['dbValue'];
                  return ChoiceChip(
                    label: Text(statusInfo['display']!),
                    selected: isSelected,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        ref
                            .read(partnerDashboardControllerProvider(partnerId)
                                .notifier,)
                            .setSelectedStatus(statusInfo['dbValue']!);
                      }
                    },
                    selectedColor: theme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : theme.primaryText,
                    ),
                    backgroundColor: theme.secondaryBackground,
                    shape:
                        StadiumBorder(side: BorderSide(color: theme.alternate)),
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
            title: FFLocalizations.of(context).getText('noaptsfound'),
            message: FFLocalizations.of(context).getText('noaptsfltr'),
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
                child: _AppointmentInfoCard(
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

class _NumberQueueView extends ConsumerWidget {
  const _NumberQueueView({
    required this.partnerId,
    required this.dashboardState,
  });

  final String partnerId;
  final dynamic dashboardState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
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
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: theme.titleMedium,
                ),
                Icon(Icons.calendar_month_outlined, color: theme.primary),
              ],
            ),
          ),
        ),
        Expanded(
          child: activeAppointments.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.people_outline,
                  title: FFLocalizations.of(context).getText('qready'),
                  message:
                      'There are no active appointments in the queue for today.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                  children: [
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
                                      .notifier,)
                              .refresh();
                        },
                      ),
                    if (upNextAppointments.isNotEmpty) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          top: currentPatient != null ? 24 : 8,
                          bottom: 8,
                        ),
                        child: Text(
                          FFLocalizations.of(context).getText('upnext'),
                          style: theme.titleLarge,
                        ),
                      ),
                      ...upNextAppointments.map(
                        (appt) => _UpNextQueueCard(
                          appointment: appt,
                          partnerId: partnerId,
                        ),
                      ),
                    ],
                    if (currentPatient == null && upNextAppointments.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Column(
                          children: [
                            Text(
                              FFLocalizations.of(context).getText('qready'),
                              style: theme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              FFLocalizations.of(context).getText('callnext'),
                              style: theme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            FFButtonWidget(
                              onPressed: () async {
                                await ref
                                    .read(partnerDashboardControllerProvider(
                                            partnerId,)
                                        .notifier,)
                                    .nextPatient();
                              },
                              text: FFLocalizations.of(context)
                                  .getText('callnextbtn'),
                              icon: const Icon(Icons.campaign_outlined),
                              options: FFButtonOptions(
                                height: 50,
                                color: theme.primary,
                                textStyle: theme.titleSmall.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

// Clinic dashboard views remain unchanged as they don't use the new controller
class _ClinicDashboardView extends StatefulWidget {
  const _ClinicDashboardView({required this.partnerId});
  final String partnerId;

  @override
  State<_ClinicDashboardView> createState() => _ClinicDashboardViewState();
}

class _ClinicDashboardViewState extends State<_ClinicDashboardView> {
  DashboardView _currentView = DashboardView.schedule;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SegmentedButton<DashboardView>(
            segments: [
              ButtonSegment(
                value: DashboardView.schedule,
                label: Text(FFLocalizations.of(context).getText('allapts')),
                icon: const Icon(Icons.calendar_month),
              ),
              ButtonSegment(
                value: DashboardView.analytics,
                label: Text(
                  FFLocalizations.of(context).getText('clncanalytics'),
                ),
                icon: const Icon(Icons.bar_chart),
              ),
            ],
            selected: {_currentView},
            onSelectionChanged: (newSelection) {
              setState(() => _currentView = newSelection.first);
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              foregroundColor: FlutterFlowTheme.of(context).primaryText,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: FlutterFlowTheme.of(context).primary,
            ),
          ),
        ),
        Expanded(
          child: _currentView == DashboardView.schedule
              ? _ClinicScheduleView(clinicId: widget.partnerId)
              : _ClinicAnalyticsView(clinicId: widget.partnerId),
        ),
      ],
    );
  }
}

class _ClinicScheduleView extends StatefulWidget {
  const _ClinicScheduleView({required this.clinicId});
  final String clinicId;

  @override
  State<_ClinicScheduleView> createState() => _ClinicScheduleViewState();
}

class _ClinicScheduleViewState extends State<_ClinicScheduleView> {
  late Future<List<MedicalPartnersRow>> _doctorsFuture;
  String? _selectedDoctorId;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _doctorsFuture = MedicalPartnersTable().queryRows(
      queryFn: (q) => q.eq('parent_clinic_id', widget.clinicId),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments() {
    return Supabase.instance.client.rpc(
      'get_clinic_appointments',
      params: {
        'clinic_id_arg': widget.clinicId,
        'doctor_id_arg': _selectedDoctorId,
      },
    ).then((data) => List<Map<String, dynamic>>.from(data as List));
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: FutureBuilder<List<MedicalPartnersRow>>(
            future: _doctorsFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 50);
              }
              final doctors = snapshot.data!;
              return DropdownButtonFormField<String>(
                value: _selectedDoctorId,
                hint: Text(FFLocalizations.of(context).getText('fltrdoc')),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: theme.secondaryBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                items: [
                  DropdownMenuItem<String>(
                    value: null,
                    child: Text(FFLocalizations.of(context).getText('alldocs')),
                  ),
                  ...doctors.map(
                    (doc) => DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(doc.fullName ?? 'Unnamed Doctor'),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorId = value;
                    _refreshKey++;
                  });
                },
              );
            },
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            key: ValueKey(_refreshKey),
            future: _fetchAppointments(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.calendar_today_rounded,
                  title: FFLocalizations.of(context).getText('noaptsfound'),
                  message: FFLocalizations.of(context).getText('noaptsfltr'),
                );
              }

              final appointments = snapshot.data!;
              return ListView.builder(
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
                        style: theme.titleMedium,
                      ),
                      subtitle: Text(
                        'With: ${appt['doctor_name'] as String? ?? 'N/A'}\nStatus: ${getLocalizedStatus(context, appt['status'] as String)}',
                        style: theme.bodySmall,
                      ),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(time),
                            style: theme.bodySmall,
                          ),
                          Text(
                            DateFormat.jm().format(time),
                            style: theme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ClinicAnalyticsView extends StatelessWidget {
  const _ClinicAnalyticsView({required this.clinicId});
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
          return Center(
            child: Text(
              FFLocalizations.of(context).getText('loadanalyticsfail'),
            ),
          );
        }

        final summary = snapshot.data!['summary'] as Map<String, dynamic>;
        final weekly =
            List<Map<String, dynamic>>.from(snapshot.data!['weekly'] as List);

        return _AnalyticsViewContent(
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

class _AnalyticsView extends StatefulWidget {
  const _AnalyticsView({required this.partnerId});
  final String partnerId;

  @override
  State<_AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<_AnalyticsView> {
  late Future<_AnalyticsData> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _fetchAllAnalytics();
  }

  Future<_AnalyticsData> _fetchAllAnalytics() async {
    final results = await Future.wait([
      _fetchWeeklyStats(),
      _fetchSummaryStats(),
    ]);
    return _AnalyticsData(
      weeklyStats: results[0] as List<Map<String, dynamic>>,
      summaryStats: results[1] as Map<String, int>,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchWeeklyStats() {
    return Supabase.instance.client.rpc(
      'get_weekly_appointment_stats',
      params: {
        'partner_id_arg': widget.partnerId,
      },
    ).then((data) => List<Map<String, dynamic>>.from(data as List));
  }

  Future<Map<String, int>> _fetchSummaryStats() async {
    final data = await Supabase.instance.client.rpc(
      'get_partner_analytics',
      params: {'partner_id_arg': widget.partnerId},
    );

    final summary = data as Map<String, dynamic>;

    return {
      'total': summary['total'] as int? ?? 0,
      'week_completed': summary['week_completed'] as int? ?? 0,
      'month_completed': summary['month_completed'] as int? ?? 0,
      'partner_canceled': summary['partner_canceled'] as int? ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AnalyticsData>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Text(
              FFLocalizations.of(context).getText('loadanalyticsfail'),
            ),
          );
        }
        final data = snapshot.data!;
        return _AnalyticsViewContent(
          summaryStats: data.summaryStats,
          weeklyStats: data.weeklyStats,
        );
      },
    );
  }
}

class _AnalyticsViewContent extends StatelessWidget {
  const _AnalyticsViewContent({
    required this.summaryStats,
    required this.weeklyStats,
  });

  final Map<String, int> summaryStats;
  final List<Map<String, dynamic>> weeklyStats;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final maxValue = weeklyStats
        .map((d) => d['appointment_count'] as int)
        .fold<int>(0, (max, current) => current > max ? current : max)
        .toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Completed Appointments - Last 7 Days', style: theme.titleLarge),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 5 : maxValue + 2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => theme.secondaryText,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = weeklyStats[group.x];
                      return BarTooltipItem(
                        '${day['day_of_week']}\n',
                        TextStyle(
                          color: theme.secondaryBackground,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: rod.toY.toInt().toString(),
                            style: TextStyle(
                              color: theme.secondaryBackground,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        if (value.toInt() >= weeklyStats.length) {
                          return const SizedBox();
                        }
                        final day =
                            weeklyStats[value.toInt()]['day_of_week'] as String;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(day, style: theme.bodySmall),
                        );
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        if (value % 2 != 0 || value > maxValue + 1) {
                          return const SizedBox();
                        }
                        return Text(
                          value.toInt().toString(),
                          style: theme.bodySmall,
                          textAlign: TextAlign.left,
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: weeklyStats
                    .mapIndexed(
                      (i, dayData) => BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: (dayData['appointment_count'] as int)
                                .toDouble(),
                            color: theme.primary,
                            width: 16,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    )
                    .toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.alternate,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _AnalyticsCard(
                label: 'Total Appointments',
                value: summaryStats['total']!,
              ),
              _AnalyticsCard(
                label: 'Completed This Week',
                value: summaryStats['week_completed']!,
              ),
              _AnalyticsCard(
                label: 'Completed This Month',
                value: summaryStats['month_completed']!,
              ),
              _AnalyticsCard(
                label: 'Canceled By You',
                value: summaryStats['partner_canceled']!,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AnalyticsCard extends StatelessWidget {
  const _AnalyticsCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      width: (MediaQuery.of(context).size.width / 2) - 24,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: theme.primaryBackground,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(value.toString(), style: theme.displaySmall),
          const SizedBox(height: 8),
          Text(label, style: theme.labelMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _AnalyticsData {
  final Map<String, int> summaryStats;
  final List<Map<String, dynamic>> weeklyStats;
  _AnalyticsData({required this.summaryStats, required this.weeklyStats});
}

class _AppointmentInfoCard extends ConsumerWidget {
  const _AppointmentInfoCard({
    required this.appointment,
    required this.partnerId,
  });

  final dynamic appointment;
  final String partnerId;

  Color getStatusColor(BuildContext context, String? status) {
    final theme = FlutterFlowTheme.of(context);
    switch (status) {
      case 'Confirmed':
      case 'Completed':
        return theme.success;
      case 'Cancelled_ByUser':
      case 'Cancelled_ByPartner':
      case 'NoShow':
        return theme.error;
      case 'Pending':
      case 'Rescheduled':
        return theme.warning;
      default:
        return theme.secondaryText;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
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
      shadowColor: theme.primaryBackground,
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
                      style: theme.bodyMedium.copyWith(
                        color: theme.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(displayName, style: theme.titleMedium),
                    Text(
                      displayPhone,
                      style: theme.bodySmall.copyWith(
                        color: theme.secondaryText,
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
    final theme = FlutterFlowTheme.of(context);
    final controller =
        ref.read(partnerDashboardControllerProvider(partnerId).notifier);

    if (status == 'Pending') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FFButtonWidget(
            onPressed: () async {
              await controller.cancelAppointment(
                  appointmentId, 'Declined by partner',);
            },
            text: 'Decline',
            options: FFButtonOptions(
              height: 36,
              color: theme.secondaryBackground,
              textStyle: theme.bodyMedium.copyWith(color: theme.error),
              elevation: 1,
              borderSide: BorderSide(color: theme.alternate),
            ),
          ),
          const SizedBox(width: 8),
          FFButtonWidget(
            onPressed: () async {
              await controller.confirmAppointment(appointmentId);
            },
            text: 'Confirm',
            options: FFButtonOptions(
              height: 36,
              color: theme.success,
              textStyle: theme.bodyMedium.copyWith(color: Colors.white),
            ),
          ),
        ],
      );
    }

    if (status == 'Confirmed') {
      return Row(
        children: [
          Expanded(
            child: FFButtonWidget(
              onPressed: () async {
                await controller.completeAppointment(appointmentId);
              },
              text: FFLocalizations.of(context).getText('markcomp'),
              icon: const Icon(Icons.check_circle_outline),
              options: FFButtonOptions(
                width: double.infinity,
                height: 40,
                color: theme.primary,
                textStyle: theme.titleSmall.copyWith(color: Colors.white),
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: theme.secondaryText),
            onSelected: (value) async {
              if (value == 'no-show') {
                await controller.noShow(appointmentId);
              } else if (value == 'cancel') {
                final confirmed = await showStyledConfirmationDialog(
                  context: context,
                  title: FFLocalizations.of(context).getText('cnclaptq'),
                  content: 'Are you sure you want to cancel this appointment?',
                  confirmText: 'Confirm',
                );
                if (confirmed) {
                  await controller.cancelAppointment(
                      appointmentId, 'Canceled by partner',);
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

class _UpNextQueueCard extends ConsumerWidget {
  const _UpNextQueueCard({
    required this.appointment,
    required this.partnerId,
  });

  final dynamic appointment;
  final String partnerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = FlutterFlowTheme.of(context);
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
                backgroundColor: theme.accent1.withAlpha(25),
                child: Text(
                  '$appointmentNumber',
                  style: theme.titleMedium.copyWith(color: theme.primary),
                ),
              ),
              title: Text(displayName, style: theme.titleMedium),
              trailing: PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: theme.secondaryText),
                onSelected: (value) async {
                  final controller = ref.read(
                      partnerDashboardControllerProvider(partnerId).notifier,);

                  if (value == 'cancel') {
                    final confirmed = await showStyledConfirmationDialog(
                      context: context,
                      title: FFLocalizations.of(context).getText('cnclaptq'),
                      content: 'Are you sure you want to cancel this request?',
                      confirmText: 'Confirm',
                    );
                    if (confirmed) {
                      await controller.cancelAppointment(
                          appointmentId, 'Canceled by partner',);
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
