// lib/features/reviews/data/review_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import 'review_model.dart';

part 'review_repository.g.dart';

/// Repository for review-related operations.
///
/// Abstracts all Supabase interactions for reviews following Clean Architecture.
@riverpod
ReviewRepository reviewRepository(ReviewRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ReviewRepository(supabase);
}

class ReviewRepository {
  ReviewRepository(this._supabase);

  final SupabaseClient _supabase;

  /// Submits a review for a completed appointment.
  ///
  /// Calls the `submit_review` RPC function with proper validation.
  /// The server enforces a 48-hour window from completion time.
  Future<void> submitReview({
    required int appointmentId,
    required double rating,
    required String reviewText,
  }) async {
    try {
      await _supabase.rpc(
        'submit_review',
        params: {
          'appointment_id_arg': appointmentId,
          'rating_arg': rating,
          'review_text_arg': reviewText,
        },
      );
    } catch (e) {
      throw ReviewException('Failed to submit review: $e');
    }
  }

  /// Fetches all reviews for a specific partner with user information.
  ///
  /// Calls the `get_reviews_with_user_names` RPC function.
  Future<List<ReviewModel>> getReviewsWithUserNames(String partnerId) async {
    try {
      final response = await _supabase.rpc(
        'get_reviews_with_user_names',
        params: {'partner_id_arg': partnerId},
      );

      final reviews = (response as List)
          .map((data) => ReviewModel.fromSupabase(
                data as Map<String, dynamic>,
              ),)
          .toList();

      return reviews;
    } catch (e) {
      throw ReviewException('Failed to fetch reviews: $e');
    }
  }

  /// Client-side validation for review submission.
  ///
  /// Checks if the appointment is eligible for review submission.
  /// Returns null if valid, otherwise returns an error message.
  String? validateReviewEligibility({
    required String status,
    required bool hasReview,
    required DateTime? completedAt,
  }) {
    if (status != 'Completed') {
      return 'You can only review completed appointments.';
    }

    if (hasReview) {
      return 'A review has already been submitted for this appointment.';
    }

    if (completedAt == null) {
      return 'This appointment has not been marked as completed yet.';
    }

    final now = DateTime.now().toUtc();
    final deadline = completedAt.add(const Duration(hours: 48));

    if (now.isAfter(deadline)) {
      return 'The 48-hour review window has expired.';
    }

    return null; // Valid
  }
}

/// Custom exception for review-related errors.
class ReviewException implements Exception {
  ReviewException(this.message);

  final String message;

  @override
  String toString() => 'ReviewException: $message';
}
