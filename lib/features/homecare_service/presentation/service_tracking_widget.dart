// lib/features/homecare_service/presentation/service_tracking_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/service_providers.dart';
import 'service_tracking_controller.dart';

/// Widget for tracking service progress and confirmations
class ServiceTrackingWidget extends ConsumerWidget {
  const ServiceTrackingWidget({
    super.key,
    required this.requestId,
    required this.userRole, // 'patient' or 'partner'
  });

  final String requestId;
  final String userRole;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final serviceStatus = ref.watch(serviceStatusProvider(requestId));

    return serviceStatus.when(
      data: (status) {
        final currentStatus = status['status'] as String;
        final serviceStartedAt = status['service_started_at'] as String?;
        final serviceCompletedAt = status['service_completed_at'] as String?;
        final patientConfirmedAt = status['patient_confirmed_at'] as String?;
        final paymentStatus = status['payment_status'] as String;

        final isPaid = paymentStatus == 'paid';
        final isInProgress = currentStatus == 'in_progress';
        final isServiceCompleted = currentStatus == 'service_completed';
        final isCompleted = currentStatus == 'completed';

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Service Tracking',
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Progress Tracker
                _buildProgressTracker(
                  isPaid: isPaid,
                  isInProgress: isInProgress,
                  isServiceCompleted: isServiceCompleted,
                  isCompleted: isCompleted,
                  theme: theme,
                ),

                const SizedBox(height: 32),

                // Action Buttons
                if (userRole == 'partner') ...[
                  // Partner Actions
                  if (isPaid && !isInProgress && !isServiceCompleted)
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(serviceTrackingControllerProvider.notifier)
                            .markStarted(requestId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Service marked as started'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Mark as Started'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  if (isInProgress && !isServiceCompleted)
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(serviceTrackingControllerProvider.notifier)
                            .markCompleted(requestId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Service marked as completed! Waiting for patient confirmation'),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Mark as Completed'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                    ),
                ],

                if (userRole == 'patient') ...[
                  // Patient Actions
                  if (isServiceCompleted && !isCompleted) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline,
                                  color: Colors.orange.shade700),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Please confirm that you received the service',
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The service will be auto-confirmed in 24 hours if you don\'t respond.',
                            style: textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () async {
                        await ref
                            .read(serviceTrackingControllerProvider.notifier)
                            .confirmReceived(requestId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Service confirmed! Thank you.'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirm Service Received'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                        backgroundColor: Colors.green.shade600,
                      ),
                    ),
                  ],
                ],

                // Completed Status
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '✅ Service completed and confirmed',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error: $e'),
      ),
    );
  }

  Widget _buildProgressTracker({
    required bool isPaid,
    required bool isInProgress,
    required bool isServiceCompleted,
    required bool isCompleted,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        _buildStep(
          icon: Icons.payment,
          title: 'Payment Received',
          isCompleted: isPaid,
          isActive: !isPaid,
          theme: theme,
        ),
        _buildConnector(isCompleted: isPaid, theme: theme),
        _buildStep(
          icon: Icons.play_circle,
          title: 'Service in Progress',
          isCompleted: isInProgress || isServiceCompleted || isCompleted,
          isActive: isPaid && !isInProgress,
          theme: theme,
        ),
        _buildConnector(
          isCompleted: isInProgress || isServiceCompleted || isCompleted,
          theme: theme,
        ),
        _buildStep(
          icon: Icons.check_circle,
          title: 'Service Completed',
          isCompleted: isServiceCompleted || isCompleted,
          isActive: isInProgress && !isServiceCompleted,
          theme: theme,
        ),
        _buildConnector(
          isCompleted: isServiceCompleted || isCompleted,
          theme: theme,
        ),
        _buildStep(
          icon: Icons.verified,
          title: 'Patient Confirmed',
          isCompleted: isCompleted,
          isActive: isServiceCompleted && !isCompleted,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String title,
    required bool isCompleted,
    required bool isActive,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCompleted
                ? Colors.green.shade600
                : isActive
                    ? colorScheme.primary.withOpacity(0.2)
                    : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isCompleted
                ? Colors.white
                : isActive
                    ? colorScheme.primary
                    : Colors.grey.shade600,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              fontWeight:
                  isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
              color: isCompleted
                  ? Colors.green.shade900
                  : isActive
                      ? colorScheme.primary
                      : Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({
    required bool isCompleted,
    required ThemeData theme,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 15),
      width: 3,
      height: 24,
      color: isCompleted ? Colors.green.shade600 : Colors.grey.shade300,
    );
  }
}
