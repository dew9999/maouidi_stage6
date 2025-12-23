// lib/features/patient/presentation/patient_dashboard_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../../appointments/data/appointment_repository.dart';
import 'patient_dashboard_state.dart';

part 'patient_dashboard_controller.g.dart';

/// Controller for the Patient Dashboard.
///
/// Manages appointment data for patients, including loading, canceling,
/// and submitting reviews.
@riverpod
class PatientDashboardController extends _$PatientDashboardController {
  @override
  Future<PatientDashboardState> build() async {
    return _loadInitialData();
  }

  Future<PatientDashboardState> _loadInitialData() async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      final userId = supabase.auth.currentUser?.id;

      if (userId == null) {
        return const PatientDashboardState(
          errorMessage: 'User not authenticated',
        );
      }

      final repository = ref.read(appointmentRepositoryProvider);

      // Fetch all appointment types in parallel
      final results = await Future.wait([
        repository.fetchPatientAppointments(
          userId,
          ['Pending', 'Confirmed', 'Rescheduled'],
          isUpcoming: true,
        ),
        repository.fetchPatientAppointments(userId, ['Completed']),
        repository.fetchPatientAppointments(
          userId,
          ['Cancelled_ByUser', 'Cancelled_ByPartner', 'NoShow'],
        ),
      ]);

      return PatientDashboardState(
        upcomingAppointments: results[0],
        completedAppointments: results[1],
        canceledAppointments: results[2],
        isLoading: false,
      );
    } catch (e) {
      return PatientDashboardState(
        errorMessage: 'Failed to load appointments: $e',
      );
    }
  }

  /// Reload all appointment data.
  Future<void> loadData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _loadInitialData());
  }

  /// Cancel an appointment.
  Future<void> cancelAppointment(int appointmentId) async {
    try {
      final repository = ref.read(appointmentRepositoryProvider);
      await repository.cancelAndReorderQueue(appointmentId);

      // Reload data after successful cancellation
      await loadData();
    } catch (e) {
      // Propagate error (UI can handle via AsyncValue.error)
      rethrow;
    }
  }

  /// Submit a review for a completed appointment.
  Future<void> submitReview(
    int appointmentId,
    double rating,
    String reviewText,
  ) async {
    try {
      final supabase = ref.read(supabaseClientProvider);
      await supabase.rpc('submit_review', params: {
        'appointment_id_arg': appointmentId,
        'rating_arg': rating,
        'review_text_arg': reviewText,
      },);

      // Reload data after successful review submission
      await loadData();
    } catch (e) {
      rethrow;
    }
  }
}

/// Stream provider for real-time upcoming appointments.
@riverpod
Stream<List<Map<String, dynamic>>> upcomingAppointmentsStream(
  UpcomingAppointmentsStreamRef ref,
) {
  final supabase = ref.watch(supabaseClientProvider);
  final userId = supabase.auth.currentUser?.id;

  if (userId == null) {
    return Stream.value([]);
  }

  final repository = ref.watch(appointmentRepositoryProvider);
  return repository.watchPatientAppointments(
    userId,
    ['Pending', 'Confirmed', 'Rescheduled'],
    isUpcoming: true,
  );
}
