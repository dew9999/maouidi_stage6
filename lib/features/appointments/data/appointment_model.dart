// lib/features/appointments/data/appointment_model.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

/// Immutable data model for appointments.
///
/// Maps to the return type of `get_partner_dashboard_appointments` RPC function.
@freezed
class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
    required int id,
    required String partnerId,
    required String bookingUserId,
    String? onBehalfOfPatientName,
    required DateTime appointmentTime,
    required String status,
    String? onBehalfOfPatientPhone,
    int? appointmentNumber,
    @Default(false) bool isRescheduled,
    DateTime? completedAt,
    @Default(false) bool hasReview,
    String? caseDescription,
    String? patientLocation,
    String? patientFirstName,
    String? patientLastName,
    String? patientPhone,
  }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) =>
      _$AppointmentModelFromJson(json);

  /// Helper to convert from Supabase RPC response
  factory AppointmentModel.fromSupabase(Map<String, dynamic> data) {
    return AppointmentModel(
      id: data['id'] as int,
      partnerId: data['partner_id'] as String,
      bookingUserId: data['booking_user_id'] as String,
      onBehalfOfPatientName: data['on_behalf_of_patient_name'] as String?,
      appointmentTime: DateTime.parse(data['appointment_time'] as String),
      status: data['status'] as String,
      onBehalfOfPatientPhone: data['on_behalf_of_patient_phone'] as String?,
      appointmentNumber: data['appointment_number'] as int?,
      isRescheduled: data['is_rescheduled'] as bool? ?? false,
      completedAt: data['completed_at'] != null
          ? DateTime.parse(data['completed_at'] as String)
          : null,
      hasReview: data['has_review'] as bool? ?? false,
      caseDescription: data['case_description'] as String?,
      patientLocation: data['patient_location'] as String?,
      patientFirstName: data['patient_first_name'] as String?,
      patientLastName: data['patient_last_name'] as String?,
      patientPhone: data['patient_phone'] as String?,
    );
  }
}
