// lib/features/appointments/presentation/appointments_stream_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/appointment_model.dart';
import '../data/appointment_repository.dart';

part 'appointments_stream_provider.g.dart';

/// Provides a real-time stream of appointments for a specific partner.
///
/// This stream uses Supabase Realtime to automatically update when
/// appointments are added, modified, or deleted. Partners will see
/// new bookings instantly without refreshing.
@riverpod
Stream<List<AppointmentModel>> appointmentsStream(
  AppointmentsStreamRef ref,
  String partnerId,
) {
  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.watchPartnerAppointments(partnerId);
}
