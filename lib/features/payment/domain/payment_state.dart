// lib/features/payment/domain/payment_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_state.freezed.dart';

/// Payment state for Chargily integration
@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;

  const factory PaymentState.loading() = _Loading;

  const factory PaymentState.redirecting({
    required String checkoutUrl,
    required String checkoutId,
  }) = _Redirecting;

  const factory PaymentState.success({
    required String transactionId,
  }) = _Success;

  const factory PaymentState.failure({
    required String error,
  }) = _Failure;
}
