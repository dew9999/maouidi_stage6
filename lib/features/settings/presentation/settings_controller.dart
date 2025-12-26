import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/settings_state.dart';

part 'settings_controller.g.dart';

// -----------------------------------------------------------------------------
// Patient Settings Controller
// -----------------------------------------------------------------------------

@riverpod
class PatientSettingsController extends _$PatientSettingsController {
  @override
  Future<PatientSettingsState> build() async {
    return _loadPatientData();
  }

  Future<PatientSettingsState> _loadPatientData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return const PatientSettingsState();
    }

    try {
      final data = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', user.id)
          .single();

      return PatientSettingsState(
        displayName: data['display_name'] as String? ?? '',
        email: data['email'] as String? ?? user.email ?? '',
        phoneNumber: data['phone_number'] as String? ?? '',
        photoUrl: data['photo_url'] as String? ?? '',
        notificationsEnabled: true, // simplified default
        isLoading: false,
      );
    } catch (e) {
      return const PatientSettingsState();
    }
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data(
          state.value!.copyWith(notificationsEnabled: isEnabled));
    }
    // Optimistic update - in real app, save to DB here
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

// -----------------------------------------------------------------------------
// Partner Settings Controller
// -----------------------------------------------------------------------------

@riverpod
class PartnerSettingsController extends _$PartnerSettingsController {
  @override
  Future<PartnerSettingsState> build() async {
    return _loadPartnerData();
  }

  Future<PartnerSettingsState> _loadPartnerData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const PartnerSettingsState();

    try {
      final data = await Supabase.instance.client
          .from('medical_partners')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data == null) return const PartnerSettingsState();

      return PartnerSettingsState(
        fullName: data['full_name'] as String? ?? '',
        email: user.email ?? '',
        category: data['category'] as String? ?? 'Doctors',
        specialty: data['specialty'] as String?,
        location: data['address'] as String?,
        isActive: data['is_active'] as bool? ?? false,
        notificationsEnabled: true,
        bookingSystemType:
            data['booking_system_type'] as String? ?? 'time_based',
        confirmationMode: data['confirmation_mode'] as String? ?? 'manual',
        dailyLimit: data['daily_limit'] as int? ?? 0,
        workingHours: _parseWorkingHours(data['working_hours']),
        closedDays: _parseClosedDays(data['closed_days']),
        isLoading: false,
      );
    } catch (e) {
      return const PartnerSettingsState();
    }
  }

  Map<String, List<String>> _parseWorkingHours(dynamic data) {
    if (data == null) return {};
    Map<String, List<String>> result = {};

    if (data is Map) {
      data.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          // Handle legacy single-string case if necessary or comma separated
          result[key.toString()] = [value];
        }
      });
    }
    return result;
  }

  List<DateTime> _parseClosedDays(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) => DateTime.parse(e.toString())).toList();
  }

  // --- Actions ---

  Future<void> updateSpecialty(String? value) async {
    if (value == null || !state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(specialty: value));
  }

  Future<void> updateClinic(String? value) async {
    if (value == null || !state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(location: value));
  }

  Future<void> updateIsActive(bool value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(isActive: value));
  }

  Future<void> toggleNotifications(bool value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(notificationsEnabled: value));
  }

  Future<void> updateBookingSystem(String value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(bookingSystemType: value));
  }

  Future<void> updateDailyLimit(int limit) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(dailyLimit: limit));
  }

  Future<void> updateConfirmationMode(String value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(confirmationMode: value));
  }

  // --- Granular Working Hours Actions ---

  Map<String, List<String>> _getCurrentHours() {
    return state.value?.workingHours != null
        ? Map<String, List<String>>.from(state.value!.workingHours)
        : {};
  }

  void _updateHoursState(Map<String, List<String>> newHours) {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(workingHours: newHours));
  }

  Future<void> addWorkingHourSlot(String day) async {
    if (!state.hasValue) return;
    final hours = _getCurrentHours();
    if (!hours.containsKey(day)) {
      hours[day] = [];
    }
    // Default slot
    hours[day]!.add("09:00-17:00");
    _updateHoursState(hours);
  }

  Future<void> removeWorkingHourSlot(String day, int index) async {
    if (!state.hasValue) return;
    final hours = _getCurrentHours();
    if (hours.containsKey(day) && hours[day]!.length > index) {
      hours[day]!.removeAt(index);
      // If list is empty, remove key? Or keep empty list?
      // UI suggests keeping key means "Enabled" but empty slots.
      // Usually removing all slots implies disabling the day.
      if (hours[day]!.isEmpty) {
        hours.remove(day);
      }
      _updateHoursState(hours);
    }
  }

  Future<void> updateWorkingHourSlot(
      String day, int index, String newSlot) async {
    if (!state.hasValue) return;
    final hours = _getCurrentHours();
    if (hours.containsKey(day) && hours[day]!.length > index) {
      hours[day]![index] = newSlot;
      _updateHoursState(hours);
    }
  }

  Future<void> setDayAvailability(String day, bool isOpen) async {
    if (!state.hasValue) return;
    final hours = _getCurrentHours();
    if (isOpen) {
      if (!hours.containsKey(day)) {
        hours[day] = ["09:00-17:00"];
      }
    } else {
      hours.remove(day);
    }
    _updateHoursState(hours);
  }

  // Legacy bulk update method, updated for List support
  Future<void> updateWorkingHours(Map<String, List<String>> hours) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(workingHours: hours));
  }

  Future<void> addClosedDay(DateTime day) async {
    if (!state.hasValue) return;
    final currentDays = List<DateTime>.from(state.value!.closedDays);

    if (!currentDays.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day)) {
      currentDays.add(day);
      state = AsyncValue.data(state.value!.copyWith(closedDays: currentDays));
    }
  }

  Future<void> removeClosedDay(DateTime day) async {
    if (!state.hasValue) return;
    final currentDays = List<DateTime>.from(state.value!.closedDays);

    currentDays.removeWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day);

    state = AsyncValue.data(state.value!.copyWith(closedDays: currentDays));
  }

  Future<void> handleEmergency() async {
    // RPC placeholder
  }

  Future<void> saveAllSettings() async {
    final currentState = state.value;
    if (currentState == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    state = AsyncValue.data(currentState.copyWith(isSaving: true));

    try {
      await Supabase.instance.client.from('medical_partners').update({
        'specialty': currentState.specialty,
        'address': currentState.location,
        'is_active': currentState.isActive,
        'booking_system_type': currentState.bookingSystemType,
        'confirmation_mode': currentState.confirmationMode,
        'daily_limit': currentState.dailyLimit,
        'working_hours': currentState
            .workingHours, // Directly save Map<String, List<String>>
        'closed_days':
            currentState.closedDays.map((e) => e.toIso8601String()).toList(),
      }).eq('id', user.id);

      state = AsyncValue.data(currentState.copyWith(isSaving: false));
    } catch (e) {
      state = AsyncValue.data(currentState.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save: ${e.toString()}',
      ));
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
