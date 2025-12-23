// lib/features/reviews/presentation/review_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_state.freezed.dart';

/// State for review submission.
///
/// Tracks the submission status and any errors.
@freezed
class ReviewState with _$ReviewState {
  const factory ReviewState.initial() = _Initial;
  const factory ReviewState.loading() = _Loading;
  const factory ReviewState.success() = _Success;
  const factory ReviewState.error(String message) = _Error;
}
