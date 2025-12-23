import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
class PatientSettingsState with _$PatientSettingsState {
  const factory PatientSettingsState({
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String phoneNumber,
    @Default('') String photoUrl,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PatientSettingsState;
}

@freezed
class PartnerSettingsState with _$PartnerSettingsState {
  const factory PartnerSettingsState({
    @Default('') String fullName,
    @Default('') String email,
    @Default('') String category, // <--- ADDED THIS
    String? specialty,
    String? location,
    @Default(true) bool notificationsEnabled, // <--- ADDED THIS
    @Default(false) bool isActive,
    @Default('time_based') String bookingSystemType,
    @Default('manual') String confirmationMode,
    @Default(0) int dailyLimit,
    @Default({}) Map<String, String> workingHours,
    @Default([]) List<DateTime> closedDays,
    @Default(false) bool isSaving,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PartnerSettingsState;
}
