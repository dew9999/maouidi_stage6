import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maouidi/features/settings/domain/settings_state.dart';

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
      // In case of error, return empty state with error message if needed
      return const PatientSettingsState();
    }
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    // Optimistic Update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data(
          state.value!.copyWith(notificationsEnabled: isEnabled),);
    }

    try {
      // Logic to persist notification setting to DB would go here
      // For now, we rely on the optimistic update
    } catch (e) {
      // Revert on error
      state = previousState;
    }
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
        notificationsEnabled: true, // Default or fetch from DB if column exists
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

  Map<String, String> _parseWorkingHours(dynamic data) {
    if (data == null) return {};
    if (data is Map) {
      // Ensure values are strings
      return Map<String, String>.from(data.map(
          (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),),);
    }
    return {};
  }

  List<DateTime> _parseClosedDays(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map((e) => DateTime.parse(e.toString())).toList();
  }

  // --- Actions ---

  Future<void> updateSpecialty(String? value) async {
    if (value == null) return;
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(specialty: value));
    }
  }

  Future<void> updateClinic(String? value) async {
    if (value == null) return;
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(location: value));
    }
  }

  Future<void> updateIsActive(bool value) async {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(isActive: value));
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (state.hasValue) {
      state =
          AsyncValue.data(state.value!.copyWith(notificationsEnabled: value));
    }
  }

  Future<void> updateBookingSystem(String value) async {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(bookingSystemType: value));
    }
  }

  /// Updates daily limit. Accepts [int] to match typical counter widget usage.
  Future<void> updateDailyLimit(int limit) async {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(dailyLimit: limit));
    }
  }

  Future<void> updateConfirmationMode(String value) async {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(confirmationMode: value));
    }
  }

  /// Updates working hours. Handles both `Map<String, String>` and `Map<String, List<String>>`.
  Future<void> updateWorkingHours(dynamic hours) async {
    if (!state.hasValue) return;

    Map<String, String> newHours = {};

    if (hours is Map<String, String>) {
      newHours = hours;
    } else if (hours is Map<String, List<String>>) {
      // Convert List format (e.g. ["09:00", "17:00"]) to String "09:00-17:00"
      hours.forEach((key, value) {
        if (value.isNotEmpty) {
          newHours[key] = value.join('-');
        }
      });
    } else if (hours is Map) {
      // Best effort conversion for dynamic maps
      hours.forEach((key, value) {
        newHours[key.toString()] = value.toString();
      });
    }

    state = AsyncValue.data(state.value!.copyWith(workingHours: newHours));
  }

  Future<void> addClosedDay(DateTime day) async {
    if (!state.hasValue) return;
    final currentDays = List<DateTime>.from(state.value!.closedDays);

    // Avoid duplicates
    if (!currentDays.any((d) =>
        d.year == day.year && d.month == day.month && d.day == day.day,)) {
      currentDays.add(day);
      state = AsyncValue.data(state.value!.copyWith(closedDays: currentDays));
    }
  }

  Future<void> removeClosedDay(DateTime day) async {
    if (!state.hasValue) return;
    final currentDays = List<DateTime>.from(state.value!.closedDays);

    currentDays.removeWhere(
        (d) => d.year == day.year && d.month == day.month && d.day == day.day,);

    state = AsyncValue.data(state.value!.copyWith(closedDays: currentDays));
  }

  Future<void> handleEmergency() async {
    // Placeholder for emergency cancellation logic
    // In a real app, this would trigger a Supabase RPC to cancel today's appointments
  }

  Future<void> saveAllSettings() async {
    final currentState = state.value;
    if (currentState == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    // Set saving state
    state = AsyncValue.data(currentState.copyWith(isSaving: true));

    try {
      await Supabase.instance.client.from('medical_partners').update({
        'specialty': currentState.specialty,
        'address': currentState.location,
        'is_active': currentState.isActive,
        'booking_system_type': currentState.bookingSystemType,
        'confirmation_mode': currentState.confirmationMode,
        'daily_limit': currentState.dailyLimit,
        'working_hours': currentState.workingHours,
        'closed_days':
            currentState.closedDays.map((e) => e.toIso8601String()).toList(),
      }).eq('id', user.id);

      // Reset saving state
      state = AsyncValue.data(currentState.copyWith(isSaving: false));
    } catch (e) {
      // Reset saving state on error
      state = AsyncValue.data(currentState.copyWith(
        isSaving: false,
        errorMessage: 'Failed to save: ${e.toString()}',
      ),);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
