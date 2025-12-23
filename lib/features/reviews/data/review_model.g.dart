// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReviewModelImpl _$$ReviewModelImplFromJson(Map<String, dynamic> json) =>
    _$ReviewModelImpl(
      rating: (json['rating'] as num).toDouble(),
      reviewText: json['reviewText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      firstName: json['firstName'] as String,
      gender: json['gender'] as String,
    );

Map<String, dynamic> _$$ReviewModelImplToJson(_$ReviewModelImpl instance) =>
    <String, dynamic>{
      'rating': instance.rating,
      'reviewText': instance.reviewText,
      'createdAt': instance.createdAt.toIso8601String(),
      'firstName': instance.firstName,
      'gender': instance.gender,
    };
