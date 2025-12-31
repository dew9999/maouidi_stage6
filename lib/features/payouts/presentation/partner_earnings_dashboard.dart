// lib/features/payouts/presentation/partner_earnings_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/payout_providers.dart';

/// Dashboard for partners to view earnings and payout settings
class PartnerEarningsDashboard extends ConsumerStatefulWidget {
  const PartnerEarningsDashboard({
    super.key,
    required this.partnerId,
  });

  static const String routeName = 'PartnerEarningsDashboard';
  static const String routePath = '/partner-earnings';

  final String partnerId;

  @override
  ConsumerState<PartnerEarningsDashboard> createState() =>
      _PartnerEarningsDashboardState();
}

class _PartnerEarningsDashboardState
    extends ConsumerState<PartnerEarningsDashboard> {
  String _selectedSchedule = 'weekly';

  @override
  void initState() {
    super.initState();
    _loadPayoutSchedule();
  }

  Future<void> _loadPayoutSchedule() async {
    final service = ref.read(payoutServiceProvider);
    final schedule = await service.getPayoutSchedule(widget.partnerId);
    if (mounted) {
      setState(() => _selectedSchedule = schedule);
    }
  }

  Future<void> _updatePayoutSchedule(String schedule) async {
    try {
      final service = ref.read(payoutServiceProvider);
      await service.updatePayoutSchedule(
        partnerId: widget.partnerId,
        schedule: schedule,
      );

      setState(() => _selectedSchedule = schedule);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payout schedule updated to $schedule'),
          backgroundColor: Colors.green,
        ),
      );

      // Refresh data
      ref.invalidate(currentPeriodEarningsProvider(widget.partnerId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final currentEarnings =
        ref.watch(currentPeriodEarningsProvider(widget.partnerId));
    final lifetimeEarnings =
        ref.watch(lifetimeEarningsProvider(widget.partnerId));
    final payoutHistory = ref.watch(payoutHistoryProvider(widget.partnerId));

    final service = ref.watch(payoutServiceProvider);
    final nextPayoutDate = service.getNextPayoutDate(_selectedSchedule);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'My Earnings',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentPeriodEarningsProvider(widget.partnerId));
          ref.invalidate(lifetimeEarningsProvider(widget.partnerId));
          ref.invalidate(payoutHistoryProvider(widget.partnerId));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Lifetime Earnings Card
              lifetimeEarnings.when(
                data: (total) => Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 48,
                          color: colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Lifetime Earnings',
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${total.toStringAsFixed(2)} DA',
                          style: textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: $e'),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Current Period Earnings
              currentEarnings.when(
                data: (earnings) {
                  final amount = earnings['total_earnings'] as double;
                  final numRequests = earnings['num_requests'] as int;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'This ${_selectedSchedule == 'weekly' ? 'Week' : 'Month'}',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Chip(
                                label: Text('$numRequests services'),
                                backgroundColor: colorScheme.secondaryContainer,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${amount.toStringAsFixed(2)} DA',
                            style: textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: 16,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Next payout: ${DateFormat('MMM dd, yyyy').format(nextPayoutDate)}',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading: () => const Card(
                  child: Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
                error: (e, _) => Card(child: Text('Error: $e')),
              ),

              const SizedBox(height: 24),

              // Payout Schedule Settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payout Schedule',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'weekly',
                            label: Text('Weekly'),
                            icon: Icon(Icons.calendar_view_week),
                          ),
                          ButtonSegment(
                            value: 'monthly',
                            label: Text('Monthly'),
                            icon: Icon(Icons.calendar_month),
                          ),
                        ],
                        selected: {_selectedSchedule},
                        onSelectionChanged: (Set<String> newSelection) {
                          _updatePayoutSchedule(newSelection.first);
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedSchedule == 'weekly'
                            ? '💰 Get paid every Sunday'
                            : '💰 Get paid on the last day of each month',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Payout History
              Text(
                'Payout History',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              payoutHistory.when(
                data: (history) {
                  if (history.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(48.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.history,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No payouts yet',
                              style: textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Complete services to start earning',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: history.map((payout) {
                      final amount =
                          (payout['total_earnings'] as num).toDouble();
                      final numRequests = payout['num_requests'] as int;
                      final period = payout['payout_period'] as String;
                      final status = payout['payout_status'] as String;
                      final createdAt =
                          DateTime.parse(payout['created_at'] as String);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: status == 'completed'
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            child: Icon(
                              status == 'completed'
                                  ? Icons.check
                                  : Icons.pending,
                              color: status == 'completed'
                                  ? Colors.green.shade700
                                  : Colors.orange.shade700,
                            ),
                          ),
                          title: Text(
                            '${amount.toStringAsFixed(2)} DA',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('$numRequests services completed'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Chip(
                                label: Text(
                                  status.toUpperCase(),
                                  style: const TextStyle(fontSize: 10),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              Text(
                                DateFormat('MMM dd').format(createdAt),
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
