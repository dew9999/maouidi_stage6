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
        .from('appointments')
        .select('negotiation_history, status')
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
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

    // Get existing history
    final history = List<Map<String, dynamic>>.from(
      (request['negotiation_history'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>),
    );

    // Add new entry
    history.add(negotiationEntry);

    // Update request with initial price proposal
    await _supabase
        .from('appointments')
        .update({
          'status': 'negotiating',
          'negotiated_price': proposedPrice,
          'negotiation_status': 'pending',
          'negotiation_history': history,
        })
        .eq('id', requestId)
        .eq('booking_type', 'homecare');
  }

  /// Patient or partner makes a counter-offer
  Future<void> counterOffer({
    required String requestId,
    required double counterOfferPrice,
    required String offeredBy, // 'patient' or 'partner'
  }) async {
    // Get current negotiation state
    final request = await _supabase
        .from('appointments')
        .select('negotiation_history, status')
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
        .single();

    // Validate request is in negotiating state
    if (request['status'] != 'negotiating') {
      throw Exception('Request must be in negotiating state');
    }

    // Get existing history
    final history = List<Map<String, dynamic>>.from(
      (request['negotiation_history'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>),
    );

    // Validate it's not the same person offering again
    if (history.isNotEmpty && history.last['offered_by'] == offeredBy) {
      throw Exception('Cannot counter-offer your own offer');
    }

    final currentRound = history.length;

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

    // Add new entry
    history.add(negotiationEntry);

    // Update request
    await _supabase
        .from('appointments')
        .update({
          'negotiated_price': counterOfferPrice,
          'negotiation_status': 'pending',
          'negotiation_history': history,
        })
        .eq('id', requestId)
        .eq('booking_type', 'homecare');
  }

  /// Accept the current price offer
  Future<void> acceptOffer({
    required String requestId,
  }) async {
    // Get current offer
    final request = await _supabase
        .from('appointments')
        .select('negotiated_price, platform_fee, status')
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
        .single();

    // Validate request is in negotiating state
    if (request['status'] != 'negotiating') {
      throw Exception('Request must be in negotiating state');
    }

    final negotiatedPrice = (request['negotiated_price'] as num).toDouble();
    final platformFee = (request['platform_fee'] as num?)?.toDouble() ?? 500.0;

    // Update request with agreed price
    await _supabase
        .from('appointments')
        .update({
          'status': 'confirmed',
          'negotiation_status': 'accepted',
          'negotiated_price': negotiatedPrice,
          'platform_fee': platformFee,
        })
        .eq('id', requestId)
        .eq('booking_type', 'homecare');
  }

  /// Decline the offer and cancel the request
  Future<void> declineOffer({
    required String requestId,
    required String declinedBy, // 'patient' or 'partner'
    String? reason,
  }) async {
    final status = declinedBy == 'patient' ? 'cancelled' : 'cancelled';

    await _supabase
        .from('appointments')
        .update({
          'status': status,
          'negotiation_status': 'rejected',
          'cancellation_reason': reason ?? 'Price negotiation declined',
        })
        .eq('id', requestId)
        .eq('booking_type', 'homecare');
  }

  /// Get negotiation history for a request
  Future<List<Map<String, dynamic>>> getNegotiationHistory({
    required String requestId,
  }) async {
    final request = await _supabase
        .from('appointments')
        .select('negotiation_history')
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
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
        .from('appointments')
        .select(
          'negotiated_price, negotiation_status, negotiation_history, status',
        )
        .eq('id', requestId)
        .eq('booking_type', 'homecare')
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
