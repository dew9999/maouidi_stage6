// lib/patient_dashboard/patient_dashboard_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maouidi/core/localization_helpers.dart';
import '../components/empty_state_widget.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../features/patient/presentation/patient_dashboard_controller.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class PatientDashboardWidget extends ConsumerStatefulWidget {
  const PatientDashboardWidget({super.key});

  static String routeName = 'PatientDashboard';
  static String routePath = '/patientDashboard';

  @override
  ConsumerState<PatientDashboardWidget> createState() =>
      _PatientDashboardWidgetState();
}

class _PatientDashboardWidgetState extends ConsumerState<PatientDashboardWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dashboardState = ref.watch(patientDashboardControllerProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary,
        title: Text(
          AppLocalizations.of(context)!.myapts,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 22.0,
          ),
        ),
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelStyle:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(178),
          indicatorColor: theme.colorScheme.secondary,
          indicatorWeight: 3.0,
          tabs: [
            Tab(text: AppLocalizations.of(context)!.upcoming),
            Tab(text: AppLocalizations.of(context)!.completed),
            Tab(text: AppLocalizations.of(context)!.canceled),
          ],
        ),
      ),
      body: dashboardState.when(
        data: (state) {
          if (state.errorMessage != null) {
            return Center(
              child: Text('Error: ${state.errorMessage}'),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildAppointmentList(state.upcomingAppointments),
              _buildAppointmentList(state.completedAppointments),
              _buildAppointmentList(state.canceledAppointments),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('An error occurred: $error'),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.calendar_month_outlined,
        title: AppLocalizations.of(context)!.noapts,
        message: AppLocalizations.of(context)!.noaptsmsg,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointmentData = appointments[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: PatientAppointmentCard(
            appointmentData: appointmentData,
            onCancelCompleted: () {
              ref.read(patientDashboardControllerProvider.notifier).loadData();
            },
            onReviewCompleted: () {
              ref.read(patientDashboardControllerProvider.notifier).loadData();
            },
          ),
        );
      },
    );
  }
}

class PatientAppointmentCard extends ConsumerWidget {
  const PatientAppointmentCard({
    super.key,
    required this.appointmentData,
    required this.onCancelCompleted,
    required this.onReviewCompleted,
  });

  final Map<String, dynamic> appointmentData;
  final VoidCallback onCancelCompleted;
  final VoidCallback onReviewCompleted;

  Color getStatusColor(BuildContext context, String? status) {
    final theme = Theme.of(context);
    switch (status) {
      case 'Confirmed':
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
    final status = appointmentData['status'] as String? ?? '';
    final appointmentId = appointmentData['id'];
    final canCancel = status == 'Pending' || status == 'Confirmed';

    bool canLeaveReview = false;
    if (status == 'Completed') {
      final hasReview = appointmentData['has_review'] as bool? ?? false;
      final completedAtStr = appointmentData['completed_at'] as String?;
      if (!hasReview && completedAtStr != null) {
        final completedAt = DateTime.parse(completedAtStr);
        if (DateTime.now()
            .isBefore(completedAt.add(const Duration(hours: 48)))) {
          canLeaveReview = true;
        }
      }
    }

    final partnerData =
        appointmentData['medical_partners'] as Map<String, dynamic>? ?? {};
    final partnerName = partnerData['full_name'] as String? ?? 'N/A';
    final specialty = partnerData['specialty'] as String? ??
        AppLocalizations.of(context)!.nospecialty;
    final appointmentTime =
        DateTime.parse(appointmentData['appointment_time']).toLocal();
    final appointmentNumber = appointmentData['appointment_number'] as int?;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: theme.colorScheme.surface.withAlpha(50),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: theme.colorScheme.outlineVariant, width: 1,),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat('MMM').format(appointmentTime).toUpperCase(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      Text(
                        DateFormat('d').format(appointmentTime),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partnerName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getLocalizedStatus(context, status),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: getStatusColor(context, status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (appointmentNumber != null)
                                Text(
                                  '${AppLocalizations.of(context)!.yournum} #$appointmentNumber',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              else
                                Text(
                                  DateFormat('h:mm a').format(appointmentTime),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                      color:
                                          theme.colorScheme.onSurfaceVariant,),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (canLeaveReview)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: FilledButton(
                  onPressed: () => _showReviewDialog(
                    context,
                    ref,
                    appointmentId,
                    partnerName,
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    textStyle: theme.textTheme.titleSmall,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.rate_review_outlined),
                      const SizedBox(width: 8),
                      Text(AppLocalizations.of(context)!.lvrvw),
                    ],
                  ),
                ),
              ),
            if (canCancel)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: OutlinedButton(
                  onPressed: () => _showCancelDialog(
                    context,
                    ref,
                    appointmentId,
                    partnerName,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(
                        color: theme.colorScheme.outlineVariant, width: 1,),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),),
                  ),
                  child: Text(AppLocalizations.of(context)!.cnclapt),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCancelDialog(
    BuildContext context,
    WidgetRef ref,
    int appointmentId,
    String partnerName,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        title: Text(
          AppLocalizations.of(context)!.cnclaptq,
          style: theme.textTheme.titleLarge,
        ),
        content: Text(
          '${AppLocalizations.of(context)!.cnclaptsure} $partnerName?',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              AppLocalizations.of(context)!.back,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref
                    .read(patientDashboardControllerProvider.notifier)
                    .cancelAppointment(appointmentId);

                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context)!.aptcnld),
                    backgroundColor: Colors.green,
                  ),
                );
                onCancelCompleted();
              } catch (e) {
                if (!context.mounted) return;
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${AppLocalizations.of(context)!.cnclfail}: ${e.toString()}',
                    ),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.cnclconfirm),
          ),
        ],
      ),
    );
  }

  void _showReviewDialog(
    BuildContext context,
    WidgetRef ref,
    int appointmentId,
    String partnerName,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ReviewSheet(
        appointmentId: appointmentId,
        partnerName: partnerName,
        onSuccess: onReviewCompleted,
      ),
    );
  }
}

class _ReviewSheet extends ConsumerStatefulWidget {
  const _ReviewSheet({
    required this.appointmentId,
    required this.partnerName,
    required this.onSuccess,
  });

  final int appointmentId;
  final String partnerName;
  final VoidCallback onSuccess;

  @override
  ConsumerState<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends ConsumerState<_ReviewSheet> {
  double _rating = 4.0;
  final _reviewController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      await ref.read(patientDashboardControllerProvider.notifier).submitReview(
            widget.appointmentId,
            _rating,
            _reviewController.text,
          );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.thankrev),
          backgroundColor: Colors.green,
        ),
      );
      widget.onSuccess();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppLocalizations.of(context)!.revfail}: ${e.toString()}',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.ratevisit,
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              widget.partnerName,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 6.0),
              itemBuilder: (context, _) =>
                  const Icon(Icons.star, color: Colors.orange),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _reviewController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.commentsopt,
                hintText: AppLocalizations.of(context)!.commentshint,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSubmitting ? null : _submitReview,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                textStyle: theme.textTheme.titleSmall,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),),
              ),
              child: Text(
                _isSubmitting
                    ? AppLocalizations.of(context)!.submittingrev
                    : AppLocalizations.of(context)!.submitrev,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
