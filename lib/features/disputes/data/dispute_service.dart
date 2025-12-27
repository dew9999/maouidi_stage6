// lib/features/disputes/data/dispute_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing disputes
class DisputeService {
  final SupabaseClient _supabase;

  DisputeService(this._supabase);

  /// Create a new dispute
  Future<void> createDispute({
    required String requestId,
    required String raisedBy,
    required String reason,
    required String description,
    List<String>? evidenceUrls,
  }) async {
    await _supabase.from('disputes').insert({
      'homecare_request_id': requestId,
      'raised_by': raisedBy,
      'dispute_reason': reason,
      'dispute_description': description,
      'evidence_urls': evidenceUrls ?? [],
      'status': 'open',
    });

    // Freeze partner payout for this request
    await _freezePayoutForDispute(requestId);
  }

  /// Freeze payout when dispute is opened
  Future<void> _freezePayoutForDispute(String requestId) async {
    // Update the homecare request to flag it as disputed
    await _supabase.from('homecare_requests').update({
      'status': 'disputed',
    }).eq('id', requestId);
  }

  /// Get disputes for a user
  Future<List<Map<String, dynamic>>> getUserDisputes(String userId) async {
    final disputes = await _supabase.from('disputes').select('''
          *,
          homecare_request:homecare_request_id(
            negotiated_price,
            partner:partner_id(full_name)
          )
        ''').eq('raised_by', userId).order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(disputes);
  }

  /// Get dispute by request ID
  Future<Map<String, dynamic>?> getDisputeByRequestId(String requestId) async {
    final disputes = await _supabase
        .from('disputes')
        .select()
        .eq('homecare_request_id', requestId);

    if (disputes.isEmpty) return null;
    return disputes.first;
  }
}
