// lib/features/homecare_negotiation/data/negotiation_repository.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository for homecare price negotiation operations
class NegotiationRepository {
  final SupabaseClient _supabase;

  NegotiationRepository(this._supabase);

  /// Partner proposes initial price for homecare request
  Future<void> proposePrice({
    required String requestId,
    required double proposedPrice,
  }) async {
    // Get current negotiation state
    final request = await _supabase
        .from('homecare_requests')
        .select('negotiation_round, status')
        .eq('id', requestId)
        .single();

    // Validate request is in correct state
    if (request['status'] != 'pending') {
      throw Exception('Request must be in pending state to propose price');
    }

    // Build negotiation entry
    final negotiationEntry = {
      'amount': proposedPrice,
      'offered_by': 'partner',
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Update request with initial price proposal
    await _supabase.from('homecare_requests').update({
      'status': 'negotiating',
      'current_offer': proposedPrice,
      'offered_by': 'partner',
      'negotiation_round': 1,
      'negotiation_history': [negotiationEntry],
    }).eq('id', requestId);
  }

  /// Patient or partner makes a counter-offer
  Future<void> counterOffer({
    required String requestId,
    required double counterOfferPrice,
    required String offeredBy, // 'patient' or 'partner'
  }) async {
    // Get current negotiation state
    final request = await _supabase
        .from('homecare_requests')
        .select('negotiation_round, negotiation_history, status, offered_by')
        .eq('id', requestId)
        .single();

    // Validate request is in negotiating state
    if (request['status'] != 'negotiating') {
      throw Exception('Request must be in negotiating state');
    }

    // Validate it's not the same person offering again
    if (request['offered_by'] == offeredBy) {
      throw Exception('Cannot counter-offer your own offer');
    }

    final currentRound = request['negotiation_round'] as int;

    // Check max rounds limit (5 rounds)
    if (currentRound >= 5) {
      throw Exception('Maximum negotiation rounds (5) reached');
    }

    // Build new negotiation entry
    final negotiationEntry = {
      'amount': counterOfferPrice,
      'offered_by': offeredBy,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // Get existing history
    final history = List<Map<String, dynamic>>.from(
      (request['negotiation_history'] as List)
          .map((e) => e as Map<String, dynamic>),
    );

    // Add new entry
    history.add(negotiationEntry);

    // Update request
    await _supabase.from('homecare_requests').update({
      'current_offer': counterOfferPrice,
      'offered_by': offeredBy,
      'negotiation_round': currentRound + 1,
      'negotiation_history': history,
    }).eq('id', requestId);
  }

  /// Accept the current price offer
  Future<void> acceptOffer({
    required String requestId,
  }) async {
    // Get current offer
    final request = await _supabase
        .from('homecare_requests')
        .select('current_offer, platform_fee, status')
        .eq('id', requestId)
        .single();

    // Validate request is in negotiating state
    if (request['status'] != 'negotiating') {
      throw Exception('Request must be in negotiating state');
    }

    final negotiatedPrice = request['current_offer'] as double;
    final platformFee = (request['platform_fee'] as num?)?.toDouble() ?? 500.0;

    // Update request with agreed price
    // total_amount is auto-calculated by trigger
    await _supabase.from('homecare_requests').update({
      'status': 'price_agreed',
      'negotiated_price': negotiatedPrice,
      'platform_fee': platformFee,
      // total_amount will be auto-calculated by trigger
    }).eq('id', requestId);
  }

  /// Decline the offer and cancel the request
  Future<void> declineOffer({
    required String requestId,
    required String declinedBy, // 'patient' or 'partner'
    String? reason,
  }) async {
    final status = declinedBy == 'patient'
        ? 'cancelled_by_patient'
        : 'cancelled_by_partner';

    await _supabase.from('homecare_requests').update({
      'status': status,
      'cancellation_reason': reason ?? 'Price negotiation declined',
    }).eq('id', requestId);
  }

  /// Get negotiation history for a request
  Future<List<Map<String, dynamic>>> getNegotiationHistory({
    required String requestId,
  }) async {
    final request = await _supabase
        .from('homecare_requests')
        .select('negotiation_history')
        .eq('id', requestId)
        .single();

    final history = request['negotiation_history'] as List?;
    if (history == null || history.isEmpty) {
      return [];
    }

    return List<Map<String, dynamic>>.from(
      history.map((e) => e as Map<String, dynamic>),
    );
  }

  /// Get current negotiation state
  Future<Map<String, dynamic>> getNegotiationState({
    required String requestId,
  }) async {
    final request = await _supabase
        .from('homecare_requests')
        .select(
          'current_offer, offered_by, negotiation_round, status, negotiation_history',
        )
        .eq('id', requestId)
        .single();

    return request;
  }

  /// Partner accepts homecare request and proposes initial price
  /// This combines accepting the request and proposing price in one action
  Future<void> acceptRequestWithPrice({
    required String requestId,
    required double proposedPrice,
  }) async {
    await proposePrice(
      requestId: requestId,
      proposedPrice: proposedPrice,
    );
  }
}
