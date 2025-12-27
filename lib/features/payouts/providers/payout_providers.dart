// lib/features/payouts/providers/payout_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/payout_service.dart';

part 'payout_providers.g.dart';

/// Provider for payout service
@riverpod
PayoutService payoutService(PayoutServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return PayoutService(supabase);
}

/// Provider for current period earnings
@riverpod
Future<Map<String, dynamic>> currentPeriodEarnings(
  CurrentPeriodEarningsRef ref,
  String partnerId,
) async {
  final service = ref.watch(payoutServiceProvider);
  return await service.getCurrentPeriodEarnings(partnerId);
}

/// Provider for payout history
@riverpod
Future<List<Map<String, dynamic>>> payoutHistory(
  PayoutHistoryRef ref,
  String partnerId,
) async {
  final service = ref.watch(payoutServiceProvider);
  return await service.getPayoutHistory(partnerId: partnerId);
}

/// Provider for lifetime earnings
@riverpod
Future<double> lifetimeEarnings(
  LifetimeEarningsRef ref,
  String partnerId,
) async {
  final service = ref.watch(payoutServiceProvider);
  return await service.getTotalLifetimeEarnings(partnerId);
}
