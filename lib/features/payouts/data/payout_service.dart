// lib/features/payouts/data/payout_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing partner payouts
class PayoutService {
  final SupabaseClient _supabase;

  PayoutService(this._supabase);

  /// Calculate earnings for a partner in a given period
  Future<Map<String, dynamic>> calculateEarnings({
    required String partnerId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    // Get all completed homecare requests in the period
    final requests = await _supabase
        .from('homecare_requests')
        .select('negotiated_price')
        .eq('partner_id', partnerId)
        .eq('status', 'completed')
        .gte('patient_confirmed_at', startDate.toIso8601String())
        .lte('patient_confirmed_at', endDate.toIso8601String());

    double totalEarnings = 0;
    for (final request in requests) {
      totalEarnings += (request['negotiated_price'] as num).toDouble();
    }

    return {
      'total_earnings': totalEarnings,
      'num_requests': requests.length,
      'period_start': startDate.toIso8601String(),
      'period_end': endDate.toIso8601String(),
    };
  }

  /// Get partner's payout schedule preference
  Future<String> getPayoutSchedule(String partnerId) async {
    final partner = await _supabase
        .from('medical_partners')
        .select('payout_schedule')
        .eq('id', partnerId)
        .single();

    return partner['payout_schedule'] as String? ?? 'weekly';
  }

  /// Update partner's payout schedule
  Future<void> updatePayoutSchedule({
    required String partnerId,
    required String schedule, // 'weekly' or 'monthly'
  }) async {
    await _supabase.from('medical_partners').update({
      'payout_schedule': schedule,
    }).eq('id', partnerId);
  }

  /// Get partner's current period earnings (not yet paid out)
  Future<Map<String, dynamic>> getCurrentPeriodEarnings(
      String partnerId,) async {
    final schedule = await getPayoutSchedule(partnerId);

    DateTime startDate;
    final now = DateTime.now();

    if (schedule == 'weekly') {
      // Start of current week (Monday)
      final weekday = now.weekday;
      startDate = now.subtract(Duration(days: weekday - 1));
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
    } else {
      // Start of current month
      startDate = DateTime(now.year, now.month, 1);
    }

    return await calculateEarnings(
      partnerId: partnerId,
      startDate: startDate,
      endDate: now,
    );
  }

  /// Get payout history for a partner
  Future<List<Map<String, dynamic>>> getPayoutHistory({
    required String partnerId,
    int limit = 10,
  }) async {
    final payouts = await _supabase
        .from('partner_payouts')
        .select()
        .eq('partner_id', partnerId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(payouts);
  }

  /// Get next payout date
  DateTime getNextPayoutDate(String schedule) {
    final now = DateTime.now();

    if (schedule == 'weekly') {
      // Next Sunday
      final daysUntilSunday = (7 - now.weekday) % 7;
      return now
          .add(Duration(days: daysUntilSunday == 0 ? 7 : daysUntilSunday));
    } else {
      // Last day of current month
      final nextMonth = now.month == 12 ? 1 : now.month + 1;
      final year = now.month == 12 ? now.year + 1 : now.year;
      return DateTime(year, nextMonth, 0); // Day 0 = last day of previous month
    }
  }

  /// Create payout record (would be called by cron job)
  Future<void> createPayout({
    required String partnerId,
    required String payoutPeriod,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) async {
    final earnings = await calculateEarnings(
      partnerId: partnerId,
      startDate: periodStart,
      endDate: periodEnd,
    );

    if (earnings['total_earnings'] == 0) {
      return; // No earnings, skip payout
    }

    await _supabase.from('partner_payouts').insert({
      'partner_id': partnerId,
      'payout_period': payoutPeriod,
      'period_start_date': periodStart.toIso8601String(),
      'period_end_date': periodEnd.toIso8601String(),
      'total_earnings': earnings['total_earnings'],
      'num_requests': earnings['num_requests'],
      'payout_status': 'pending',
    });
  }

  /// Get total lifetime earnings
  Future<double> getTotalLifetimeEarnings(String partnerId) async {
    final result = await _supabase.rpc('get_partner_lifetime_earnings',
        params: {'partner_id_arg': partnerId},);

    return (result as num?)?.toDouble() ?? 0;
  }
}
