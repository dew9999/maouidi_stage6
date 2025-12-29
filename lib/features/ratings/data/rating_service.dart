// lib/features/ratings/data/rating_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for partner ratings
class RatingService {
  final SupabaseClient _supabase;

  RatingService(this._supabase);

  /// Submit a rating for a completed service
  Future<void> submitRating({
    required String requestId,
    required String partnerId,
    required String patientId,
    required int rating,
    String? reviewText,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    await _supabase.from('partner_ratings').insert({
      'appointment_id': requestId,
      'partner_id': partnerId,
      'patient_id': patientId,
      'rating': rating,
      'review_text': reviewText,
    });

    // Rating average is automatically updated by trigger
  }

  /// Check if rating exists for a request
  Future<bool> hasRating(String requestId) async {
    final result = await _supabase
        .from('partner_ratings')
        .select('id')
        .eq('appointment_id', requestId);

    return result.isNotEmpty;
  }

  /// Get partner's ratings
  Future<List<Map<String, dynamic>>> getPartnerRatings({
    required String partnerId,
    int limit = 10,
  }) async {
    final ratings = await _supabase
        .from('partner_ratings')
        .select('''
          *,
          patient:patient_id(first_name, last_name)
        ''')
        .eq('partner_id', partnerId)
        .order('created_at', ascending: false)
        .limit(limit);

    return List<Map<String, dynamic>>.from(ratings);
  }

  /// Get partner's average rating
  Future<Map<String, dynamic>> getPartnerRatingStats(String partnerId) async {
    final partner = await _supabase
        .from('medical_partners')
        .select('average_rating, total_ratings')
        .eq('id', partnerId)
        .single();

    return {
      'average_rating': (partner['average_rating'] as num?)?.toDouble() ?? 0.0,
      'total_ratings': partner['total_ratings'] as int? ?? 0,
    };
  }
}
