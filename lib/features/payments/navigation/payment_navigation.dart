// lib/features/payments/navigation/payment_navigation.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Helper class for navigating through the payment flow
class PaymentNavigation {
  /// Navigate to negotiation screen
  /// Called when a homecare request needs price negotiation
  static void goToNegotiation(
    BuildContext context, {
    required String requestId,
  }) {
    context.pushNamed(
      'NegotiationScreen',
      queryParameters: {
        'requestId': requestId,
      },
    );
  }

  /// Navigate to payment screen
  /// Called when negotiation is complete and price is agreed
  static void goToPayment(
    BuildContext context, {
    required String requestId,
    required double negotiatedPrice,
    double platformFee = 500,
  }) {
    context.pushNamed(
      'PaymentScreen',
      queryParameters: {
        'requestId': requestId,
        'negotiatedPrice': negotiatedPrice.toString(),
        'platformFee': platformFee.toString(),
      },
    );
  }

  /// Navigate back to patient dashboard after payment
  static void goToDashboard(BuildContext context) {
    context.goNamed('PatientDashboard');
  }

  /// Navigate to partner dashboard after accepting request
  static void goToPartnerDashboard(BuildContext context, String partnerId) {
    context.pushNamed(
      'PartnerDashboardPage',
      queryParameters: {
        'partnerId': partnerId,
      },
    );
  }
}
