import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

@freezed
class PatientSettingsState with _$PatientSettingsState {
  const factory PatientSettingsState({
    @Default('') String displayName,
    @Default('') String email,
    @Default('') String phoneNumber,
    @Default('') String photoUrl,
    String? gender,
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
    @Default('') String photoUrl,
    String? gender,
    String? bio, // NEW: Bio field
    String? phone, // From users table
    String? state, // From users table (wilaya/state)
    @Default('') String category,
    String? specialty,
    String? location,
    @Default(true) bool notificationsEnabled,
    @Default(false) bool isActive,
    @Default('time_based') String bookingSystemType,
    @Default('manual') String confirmationMode,
    @Default(0) int dailyBookingLimit,
    double? homecarePrice, // Partner-specific homecare service price
    @Default({}) Map<String, List<String>> workingHours,
    @Default([]) List<DateTime> closedDays,
    String? ripNumber, // NEW: RIP Number (Manual Payouts)
    String? accountHolderName, // Account Holder Name
    @Default(false) bool isSaving,
    @Default(false) bool isLoading,
    String? errorMessage,
  }) = _PartnerSettingsState;
}
