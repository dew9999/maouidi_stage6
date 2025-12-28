// lib/features/partners/domain/partner_exceptions.dart

/// Base exception class for partner-related errors
class PartnerException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  PartnerException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'PartnerException [$code]: $message';
    }
    return 'PartnerException: $message';
  }
}

/// Thrown when attempting to access a partner that is not verified
class PartnerNotVerifiedException extends PartnerException {
  PartnerNotVerifiedException()
      : super(
          'Partner account not verified. Please contact support for verification.',
          code: 'PARTNER_NOT_VERIFIED',
        );
}

/// Thrown when attempting to perform actions with an inactive partner account
class PartnerInactiveException extends PartnerException {
  PartnerInactiveException()
      : super(
          'Partner account is inactive. Enable your account in settings to accept bookings.',
          code: 'PARTNER_INACTIVE',
        );
}

/// Thrown when daily booking limit has been reached
class BookingLimitExceededException extends PartnerException {
  final int limit;

  BookingLimitExceededException({required this.limit})
      : super(
          'Daily booking limit ($limit) has been reached. No more appointments can be accepted today.',
          code: 'BOOKING_LIMIT_EXCEEDED',
        );
}

/// Thrown when partner is not found in database
class PartnerNotFoundException extends PartnerException {
  final String partnerId;

  PartnerNotFoundException(this.partnerId)
      : super(
          'Partner not found with ID: $partnerId',
          code: 'PARTNER_NOT_FOUND',
        );
}

/// Thrown when partner data fails to load
class PartnerDataLoadException extends PartnerException {
  PartnerDataLoadException(String message, {dynamic originalError})
      : super(
          'Failed to load partner data: $message',
          code: 'PARTNER_DATA_LOAD_FAILED',
          originalError: originalError,
        );
}

/// Thrown when appointment operation fails
class AppointmentOperationException extends PartnerException {
  final String operation;

  AppointmentOperationException({
    required this.operation,
    required String message,
    dynamic originalError,
  }) : super(
          'Failed to $operation: $message',
          code: 'APPOINTMENT_OPERATION_FAILED',
          originalError: originalError,
        );
}

/// Thrown when analytics data fails to load
class AnalyticsLoadException extends PartnerException {
  AnalyticsLoadException({String? details, dynamic originalError})
      : super(
          details != null
              ? 'Failed to load analytics: $details'
              : 'Failed to load analytics data',
          code: 'ANALYTICS_LOAD_FAILED',
          originalError: originalError,
        );
}

/// Thrown when network request fails
class NetworkException extends PartnerException {
  NetworkException({String? details})
      : super(
          details != null
              ? 'Network error: $details'
              : 'Network connection failed. Please check your internet connection.',
          code: 'NETWORK_ERROR',
        );
}

/// Thrown when RPC function call fails
class RpcCallException extends PartnerException {
  final String functionName;

  RpcCallException({
    required this.functionName,
    String? details,
    dynamic originalError,
  }) : super(
          'RPC call to "$functionName" failed${details != null ? ': $details' : ''}',
          code: 'RPC_CALL_FAILED',
          originalError: originalError,
        );
}
