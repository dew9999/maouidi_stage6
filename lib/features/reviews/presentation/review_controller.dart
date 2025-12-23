// lib/features/reviews/presentation/review_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/review_repository.dart';
import 'review_state.dart';

part 'review_controller.g.dart';

/// Controller for review submission.
///
/// Handles validation and submission of appointment reviews.
@riverpod
class ReviewController extends _$ReviewController {
  @override
  ReviewState build() {
    return const ReviewState.initial();
  }

  /// Validates and submits a review for an appointment.
  ///
  /// Performs client-side validation before calling the repository.
  /// The server will perform additional validation including the 48-hour window.
  Future<void> submitReview({
    required int appointmentId,
    required double rating,
    required String reviewText,
    required String appointmentStatus,
    required bool hasReview,
    required DateTime? completedAt,
  }) async {
    state = const ReviewState.loading();

    final repository = ref.read(reviewRepositoryProvider);

    // Client-side validation
    final validationError = repository.validateReviewEligibility(
      status: appointmentStatus,
      hasReview: hasReview,
      completedAt: completedAt,
    );

    if (validationError != null) {
      state = ReviewState.error(validationError);
      return;
    }

    try {
      await repository.submitReview(
        appointmentId: appointmentId,
        rating: rating,
        reviewText: reviewText,
      );
      state = const ReviewState.success();
    } catch (e) {
      state = ReviewState.error('Failed to submit review: ${e.toString()}');
    }
  }

  /// Resets the state back to initial.
  void reset() {
    state = const ReviewState.initial();
  }
}
