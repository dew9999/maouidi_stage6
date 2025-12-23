// lib/features/reviews/data/review_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// Immutable data model for reviews.
///
/// Maps to the return type of `get_reviews_with_user_names` RPC function.
@freezed
class ReviewModel with _$ReviewModel {
  const factory ReviewModel({
    required double rating,
    required String reviewText,
    required DateTime createdAt,
    required String firstName,
    required String gender,
  }) = _ReviewModel;

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  /// Helper to convert from Supabase RPC response
  factory ReviewModel.fromSupabase(Map<String, dynamic> data) {
    return ReviewModel(
      rating: (data['rating'] as num).toDouble(),
      reviewText: data['review_text'] as String,
      createdAt: DateTime.parse(data['created_at'] as String),
      firstName: data['first_name'] as String,
      gender: data['gender'] as String,
    );
  }
}
