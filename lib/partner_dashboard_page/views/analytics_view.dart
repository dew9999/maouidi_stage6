// lib/partner_dashboard_page/views/analytics_view.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:maouidi/generated/l10n/app_localizations.dart';

import '../../backend/supabase/supabase.dart';
import '../../components/error_state_widget.dart';

/// Analytics view for partner dashboard - Refactored to ConsumerWidget
class AnalyticsView extends ConsumerStatefulWidget {
  const AnalyticsView({super.key, required this.partnerId});

  final String partnerId;

  @override
  ConsumerState<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends ConsumerState<AnalyticsView> {
  late Future<AnalyticsData> _analyticsFuture;

  @override
  void initState() {
    super.initState();
    _analyticsFuture = _fetchAllAnalytics();
  }

  Future<AnalyticsData> _fetchAllAnalytics() async {
    final results = await Future.wait([
      _fetchWeeklyStats(),
      _fetchSummaryStats(),
    ]);
    return AnalyticsData(
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
    return FutureBuilder<AnalyticsData>(
      future: _analyticsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return ErrorStateWidget(
            message: AppLocalizations.of(context)!.loadanalyticsfail,
            onRetry: () => setState(() {
              _analyticsFuture = _fetchAllAnalytics();
            }),
          );
        }
        final data = snapshot.data!;
        return AnalyticsViewContent(
          summaryStats: data.summaryStats,
          weeklyStats: data.weeklyStats,
        );
      },
    );
  }
}

/// Content view for analytics with charts and stats cards
class AnalyticsViewContent extends StatelessWidget {
  const AnalyticsViewContent({
    super.key,
    required this.summaryStats,
    required this.weeklyStats,
  });

  final Map<String, int> summaryStats;
  final List<Map<String, dynamic>> weeklyStats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final maxValue = weeklyStats
        .map((d) => d['appointment_count'] as int)
        .fold<int>(0, (max, current) => current > max ? current : max)
        .toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Completed Appointments - Last 7 Days',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 5 : maxValue + 2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => colorScheme.onSurfaceVariant,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final day = weeklyStats[group.x];
                      return BarTooltipItem(
                        '${day['day_of_week']}\n',
                        TextStyle(
                          color: colorScheme.surface,
                          fontWeight: FontWeight.bold,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: rod.toY.toInt().toString(),
                            style: TextStyle(
                              color: colorScheme.surface,
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
                          child: Text(day, style: textTheme.bodySmall),
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
                          style: textTheme.bodySmall,
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
                            color: colorScheme.primary,
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
                      color: colorScheme.outlineVariant,
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
              AnalyticsCard(
                label: 'Total Appointments',
                value: summaryStats['total']!,
              ),
              AnalyticsCard(
                label: 'Completed This Week',
                value: summaryStats['week_completed']!,
              ),
              AnalyticsCard(
                label: 'Completed This Month',
                value: summaryStats['month_completed']!,
              ),
              AnalyticsCard(
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

/// Individual analytics stat card
class AnalyticsCard extends StatelessWidget {
  const AnalyticsCard({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '$value',
            style: theme.textTheme.displaySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for analytics
class AnalyticsData {
  final Map<String, int> summaryStats;
  final List<Map<String, dynamic>> weeklyStats;

  AnalyticsData({
    required this.summaryStats,
    required this.weeklyStats,
  });
}
