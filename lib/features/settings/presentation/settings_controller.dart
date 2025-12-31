import 'package:flutter/foundation.dart';
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
        gender: data['gender'] as String?,
        notificationsEnabled: true,
        isLoading: false,
      );
    } catch (e) {
      return const PatientSettingsState();
    }
  }

  Future<void> toggleNotifications(bool isEnabled) async {
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.copyWith(notificationsEnabled: isEnabled),
      );
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}

// -----------------------------------------------------------------------------
// Partner Settings Controller (Database 2.0 - Using RPCs)
// -----------------------------------------------------------------------------

@riverpod
class PartnerSettingsController extends _$PartnerSettingsController {
  @override
  Future<PartnerSettingsState> build() async {
    return _loadPartnerData();
  }

  /// Load partner data using RPC (Database 2.0)
  Future<PartnerSettingsState> _loadPartnerData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const PartnerSettingsState();

    try {
      // Use the new RPC function to get merged profile
      final response = await Supabase.instance.client.rpc(
        'get_full_partner_profile',
        params: {'target_user_id': user.id},
      );

      // Response is a list with single row
      if (response == null || response.isEmpty) {
        return const PartnerSettingsState();
      }

      final data = response[0] as Map<String, dynamic>;

      return PartnerSettingsState(
        fullName: data['full_name'] as String? ?? '',
        email: data['email'] as String? ?? '',
        photoUrl: data['photo_url'] as String? ?? '',
        gender: data['gender'] as String?,
        phone: data['phone'] as String?,
        state: data['state'] as String?,
        category: data['category'] as String? ?? 'Doctors',
        specialty: data['specialty'] as String?,
        location: data['address'] as String?,
        bio: data['bio'] as String?, // NEW
        isActive: data['is_active'] as bool? ?? true, // NEW
        notificationsEnabled:
            data['notifications_enabled'] as bool? ?? true, // NEW
        bookingSystemType:
            data['booking_system_type'] as String? ?? 'time_based',
        confirmationMode:
            data['confirmation_mode'] as String? ?? 'manual', // NEW
        dailyBookingLimit: data['daily_booking_limit'] as int? ?? 0,
        homecarePrice: (data['homecare_price'] as num?)?.toDouble(),
        workingHours: _parseWorkingHours(data['working_hours']),
        closedDays: _parseClosedDays(data['closed_days']),
        isLoading: false,
      );
    } catch (e) {
      debugPrint('Partner settings load error: $e');
      return const PartnerSettingsState(
        errorMessage: 'Failed to load settings. Please try again.',
      );
    }
  }

  Map<String, List<String>> _parseWorkingHours(dynamic data) {
    if (data == null) return {};
    final Map<String, List<String>> result = {};

    if (data is Map) {
      data.forEach((key, value) {
        if (value is List) {
          result[key.toString()] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
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

  Future<void> updateBio(String value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(bio: value));
  }

  Future<void> updateSpecialty(String? value) async {
    if (value == null || !state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(specialty: value));
  }

  Future<void> updateClinic(String? value) async {
    if (value == null || !state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(location: value));
  }

  Future<void> updateState(String? value) async {
    if (value == null || !state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(state: value));
  }

  Future<void> updatePhone(String? value) async {
    if (value == null || !state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(phone: value));
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
    state = AsyncValue.data(state.value!.copyWith(dailyBookingLimit: limit));
  }

  Future<void> updateConfirmationMode(String value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(confirmationMode: value));
  }

  Future<void> updateHomecarePrice(double? value) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(homecarePrice: value));
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
    hours[day]!.add('09:00-17:00');
    _updateHoursState(hours);
  }

  Future<void> removeWorkingHourSlot(String day, int index) async {
    if (!state.hasValue) return;
    final hours = _getCurrentHours();
    if (hours.containsKey(day) && hours[day]!.length > index) {
      hours[day]!.removeAt(index);
      if (hours[day]!.isEmpty) {
        hours.remove(day);
      }
      _updateHoursState(hours);
    }
  }

  Future<void> updateWorkingHourSlot(
    String day,
    int index,
    String newSlot,
  ) async {
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
        hours[day] = ['09:00-17:00'];
      }
    } else {
      hours.remove(day);
    }
    _updateHoursState(hours);
  }

  Future<void> updateWorkingHours(Map<String, List<String>> hours) async {
    if (!state.hasValue) return;
    state = AsyncValue.data(state.value!.copyWith(workingHours: hours));
  }

  Future<void> addClosedDay(DateTime day) async {
    if (!state.hasValue) return;
    final currentDays = List<DateTime>.from(state.value!.closedDays);

    if (!currentDays.any(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    )) {
      currentDays.add(day);
      state = AsyncValue.data(state.value!.copyWith(closedDays: currentDays));
    }
  }

  Future<void> removeClosedDay(DateTime day) async {
    if (!state.hasValue) return;
    final currentDays = List<DateTime>.from(state.value!.closedDays);

    currentDays.removeWhere(
      (d) => d.year == day.year && d.month == day.month && d.day == day.day,
    );

    state = AsyncValue.data(state.value!.copyWith(closedDays: currentDays));
  }

  /// Trigger emergency mode to cancel upcoming appointments and notify patients
  Future<void> handleEmergency() async {
    try {
      await Supabase.instance.client.rpc('handle_partner_emergency');
    } catch (e) {
      debugPrint('Emergency mode error: $e');
      rethrow;
    }
  }

  /// Save all settings using RPC (Database 2.0 - Atomic Transaction)
  Future<void> saveAllSettings() async {
    final currentState = state.value;
    if (currentState == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    state = AsyncValue.data(currentState.copyWith(isSaving: true));

    try {
      // Use the new RPC that handles both tables atomically
      await Supabase.instance.client.rpc(
        'update_full_partner_profile',
        params: {
          'p_id': user.id,
          'p_specialty': currentState.specialty,
          'p_address': currentState.location,
          'p_booking_system': currentState.bookingSystemType,
          'p_limit': currentState.dailyBookingLimit,
          'p_state': currentState.state,
          'p_phone': currentState.phone,
          'p_bio': currentState.bio,
          'p_is_active': currentState.isActive,
          'p_confirmation_mode': currentState.confirmationMode,
          'p_notifications_enabled': currentState.notificationsEnabled,
        },
      );

      // Also update working_hours, closed_days, and homecare_price separately
      // (Add these to the RPC if needed, or keep separate)
      await Supabase.instance.client.from('medical_partners').update({
        'working_hours': currentState.workingHours,
        'closed_days':
            currentState.closedDays.map((e) => e.toIso8601String()).toList(),
        'homecare_price': currentState.homecarePrice,
      }).eq('id', user.id);

      state = AsyncValue.data(currentState.copyWith(isSaving: false));
    } catch (e) {
      state = AsyncValue.data(
        currentState.copyWith(
          isSaving: false,
          errorMessage: 'Failed to save: ${e.toString()}',
        ),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
  }
}
