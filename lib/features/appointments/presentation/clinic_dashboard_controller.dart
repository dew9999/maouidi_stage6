import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../backend/supabase/database/tables/medical_partners.dart';

part 'clinic_dashboard_controller.g.dart';

enum ClinicDashboardView {
  schedule,
  analytics,
}

class ClinicDashboardState {
  final List<MedicalPartnersRow> doctors;
  final List<Map<String, dynamic>> appointments;
  final String? selectedDoctorId;
  final ClinicDashboardView currentView;
  final bool isLoading;
  final String? errorMessage;

  ClinicDashboardState({
    this.doctors = const [],
    this.appointments = const [],
    this.selectedDoctorId,
    this.currentView = ClinicDashboardView.schedule,
    this.isLoading = false,
    this.errorMessage,
  });

  ClinicDashboardState copyWith({
    List<MedicalPartnersRow>? doctors,
    List<Map<String, dynamic>>? appointments,
    String? selectedDoctorId,
    ClinicDashboardView? currentView,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClinicDashboardState(
      doctors: doctors ?? this.doctors,
      appointments: appointments ?? this.appointments,
      selectedDoctorId: selectedDoctorId ?? this.selectedDoctorId,
      currentView: currentView ?? this.currentView,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

@riverpod
class ClinicDashboardController extends _$ClinicDashboardController {
  late String _clinicId;

  @override
  Future<ClinicDashboardState> build(String clinicId) async {
    _clinicId = clinicId;
    return _loadInitialData();
  }

  Future<ClinicDashboardState> _loadInitialData() async {
    try {
      final doctors = await MedicalPartnersTable().queryRows(
        queryFn: (q) => q.eq('parent_clinic_id', _clinicId),
      );

      final appointments = await _fetchAppointments(null); // Load all initially

      return ClinicDashboardState(
        doctors: doctors,
        appointments: appointments,
        isLoading: false,
      );
    } catch (e) {
      return ClinicDashboardState(
        errorMessage: 'Failed to load clinic data: ${e.toString()}',
        isLoading: false,
      );
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAppointments(
      String? doctorId,) async {
    final data = await Supabase.instance.client.rpc(
      'get_clinic_appointments',
      params: {
        'clinic_id_arg': _clinicId,
        'doctor_id_arg': doctorId,
      },
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<void> setSelectedDoctor(String? doctorId) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(isLoading: true));

    try {
      final appointments = await _fetchAppointments(doctorId);
      state = AsyncValue.data(currentState.copyWith(
        selectedDoctorId: doctorId,
        appointments: appointments,
        isLoading: false,
      ),);
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isLoading: false,
        errorMessage: 'Failed to filter appointments: ${e.toString()}',
      ),);
    }
  }

  void setView(ClinicDashboardView view) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(currentView: view));
    }
  }

  Future<void> refresh() async {
    final currentState = state.value;
    if (currentState == null) {
      ref.invalidateSelf();
      return;
    }

    // Maintain current filter
    await setSelectedDoctor(currentState.selectedDoctorId);
  }
}
