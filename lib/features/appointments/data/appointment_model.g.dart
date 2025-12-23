// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentModelImpl _$$AppointmentModelImplFromJson(
        Map<String, dynamic> json) =>
    _$AppointmentModelImpl(
      id: (json['id'] as num).toInt(),
      partnerId: json['partnerId'] as String,
      bookingUserId: json['bookingUserId'] as String,
      onBehalfOfPatientName: json['onBehalfOfPatientName'] as String?,
      appointmentTime: DateTime.parse(json['appointmentTime'] as String),
      status: json['status'] as String,
      onBehalfOfPatientPhone: json['onBehalfOfPatientPhone'] as String?,
      appointmentNumber: (json['appointmentNumber'] as num?)?.toInt(),
      isRescheduled: json['isRescheduled'] as bool? ?? false,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      hasReview: json['hasReview'] as bool? ?? false,
      caseDescription: json['caseDescription'] as String?,
      patientLocation: json['patientLocation'] as String?,
      patientFirstName: json['patientFirstName'] as String?,
      patientLastName: json['patientLastName'] as String?,
      patientPhone: json['patientPhone'] as String?,
    );

Map<String, dynamic> _$$AppointmentModelImplToJson(
        _$AppointmentModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'partnerId': instance.partnerId,
      'bookingUserId': instance.bookingUserId,
      'onBehalfOfPatientName': instance.onBehalfOfPatientName,
      'appointmentTime': instance.appointmentTime.toIso8601String(),
      'status': instance.status,
      'onBehalfOfPatientPhone': instance.onBehalfOfPatientPhone,
      'appointmentNumber': instance.appointmentNumber,
      'isRescheduled': instance.isRescheduled,
      'completedAt': instance.completedAt?.toIso8601String(),
      'hasReview': instance.hasReview,
      'caseDescription': instance.caseDescription,
      'patientLocation': instance.patientLocation,
      'patientFirstName': instance.patientFirstName,
      'patientLastName': instance.patientLastName,
      'patientPhone': instance.patientPhone,
    };
