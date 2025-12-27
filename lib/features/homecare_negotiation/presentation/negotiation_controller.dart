// lib/features/homecare_negotiation/presentation/negotiation_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/negotiation_providers.dart';

part 'negotiation_controller.g.dart';

/// Controller for managing negotiation actions
@riverpod
class NegotiationController extends _$NegotiationController {
  @override
  FutureOr<void> build() {}

  /// Partner proposes initial price
  Future<void> proposePrice({
    required String requestId,
    required double price,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(negotiationRepositoryProvider);
      await repository.proposePrice(
        requestId: requestId,
        proposedPrice: price,
      );

      // Refresh negotiation state
      ref.invalidate(negotiationStateProvider(requestId));
    });
  }

  /// Make a counter-offer
  Future<void> counterOffer({
    required String requestId,
    required double price,
    required String offeredBy,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(negotiationRepositoryProvider);
      await repository.counterOffer(
        requestId: requestId,
        counterOfferPrice: price,
        offeredBy: offeredBy,
      );

      // Refresh negotiation state
      ref.invalidate(negotiationStateProvider(requestId));
      ref.invalidate(negotiationHistoryProvider(requestId));
    });
  }

  /// Accept the current offer
  Future<void> acceptOffer({
    required String requestId,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(negotiationRepositoryProvider);
      await repository.acceptOffer(requestId: requestId);

      // Refresh negotiation state
      ref.invalidate(negotiationStateProvider(requestId));
    });
  }

  /// Decline the offer
  Future<void> declineOffer({
    required String requestId,
    required String declinedBy,
    String? reason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(negotiationRepositoryProvider);
      await repository.declineOffer(
        requestId: requestId,
        declinedBy: declinedBy,
        reason: reason,
      );

      // Refresh negotiation state
      ref.invalidate(negotiationStateProvider(requestId));
    });
  }

  /// Partner accepts request with initial price
  Future<void> acceptRequestWithPrice({
    required String requestId,
    required double price,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(negotiationRepositoryProvider);
      await repository.acceptRequestWithPrice(
        requestId: requestId,
        proposedPrice: price,
      );

      // Refresh negotiation state
      ref.invalidate(negotiationStateProvider(requestId));
      ref.invalidate(negotiationHistoryProvider(requestId));
    });
  }
}
