// lib/features/homecare_negotiation/providers/negotiation_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/negotiation_repository.dart';

part 'negotiation_providers.g.dart';

/// Provider for negotiation repository
@riverpod
NegotiationRepository negotiationRepository(NegotiationRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return NegotiationRepository(supabase);
}

/// Provider for negotiation state of a specific request
@riverpod
class NegotiationState extends _$NegotiationState {
  @override
  Future<Map<String, dynamic>> build(String requestId) async {
    final repository = ref.watch(negotiationRepositoryProvider);
    return await repository.getNegotiationState(requestId: requestId);
  }

  /// Refresh negotiation state
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(negotiationRepositoryProvider);
      return await repository.getNegotiationState(requestId: requestId);
    });
  }
}

/// Provider for negotiation history of a specific request
@riverpod
Future<List<Map<String, dynamic>>> negotiationHistory(
  NegotiationHistoryRef ref,
  String requestId,
) async {
  final repository = ref.watch(negotiationRepositoryProvider);
  return await repository.getNegotiationHistory(requestId: requestId);
}
