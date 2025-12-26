import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileState {
  final bool isEditing;
  final bool isSaving;
  final Map<String, dynamic>? profileData;

  // Form State
  final String firstName;
  final String lastName;
  final String phone;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? wilaya;

  const UserProfileState({
    this.isEditing = false,
    this.isSaving = false,
    this.profileData,
    this.firstName = '',
    this.lastName = '',
    this.phone = '',
    this.dateOfBirth,
    this.gender,
    this.wilaya,
  });

  UserProfileState copyWith({
    bool? isEditing,
    bool? isSaving,
    Map<String, dynamic>? profileData,
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? wilaya,
  }) {
    return UserProfileState(
      isEditing: isEditing ?? this.isEditing,
      isSaving: isSaving ?? this.isSaving,
      profileData: profileData ?? this.profileData,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      wilaya: wilaya ?? this.wilaya,
    );
  }
}

class UserProfileController extends AsyncNotifier<UserProfileState> {
  @override
  Future<UserProfileState> build() async {
    return _loadProfile();
  }

  Future<UserProfileState> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const UserProfileState();

    final authRepo = ref.read(authRepositoryProvider);
    final profile = await authRepo.getUserProfile(user.id);

    if (profile == null) return const UserProfileState();

    return UserProfileState(
      profileData: profile,
      firstName: profile['first_name']?.toString() ?? '',
      lastName: profile['last_name']?.toString() ?? '',
      phone: profile['phone']?.toString() ?? '',
      dateOfBirth: profile['date_of_birth'] != null
          ? DateTime.parse(profile['date_of_birth'])
          : null,
      gender: _validateGender(profile['gender']?.toString()),
      wilaya: profile['wilaya']
          ?.toString(), // Validation happens in UI if needed, or helper
    );
  }

  String? _validateGender(String? gender) {
    const validGenders = ['Male', 'Female', 'Other'];
    return validGenders.contains(gender) ? gender : null;
  }

  void toggleEditing(bool value) {
    if (state.value == null) return;

    if (!value) {
      // Reset form to original data on cancel
      final original = state.value!.profileData;
      if (original != null) {
        state = AsyncValue.data(state.value!.copyWith(
          isEditing: false,
          firstName: original['first_name']?.toString() ?? '',
          lastName: original['last_name']?.toString() ?? '',
          phone: original['phone']?.toString() ?? '',
          dateOfBirth: original['date_of_birth'] != null
              ? DateTime.parse(original['date_of_birth'])
              : null,
          gender: _validateGender(original['gender']?.toString()),
          wilaya: original['wilaya']?.toString(),
        ));
      } else {
        state = AsyncValue.data(state.value!.copyWith(isEditing: false));
      }
    } else {
      state = AsyncValue.data(state.value!.copyWith(isEditing: true));
    }
  }

  void updateField({
    String? firstName,
    String? lastName,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
    String? wilaya,
  }) {
    if (state.value == null) return;
    state = AsyncValue.data(state.value!.copyWith(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      dateOfBirth: dateOfBirth,
      gender: gender,
      wilaya: wilaya,
    ));
  }

  Future<bool> saveProfile() async {
    final currentState = state.value;
    if (currentState == null) return false;

    state = AsyncValue.data(currentState.copyWith(isSaving: true));

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No user logged in');

      final authRepo = ref.read(authRepositoryProvider);

      await authRepo.updateUserProfile(user.id, {
        'first_name': currentState.firstName,
        'last_name': currentState.lastName,
        'phone': currentState.phone,
        'date_of_birth': currentState.dateOfBirth?.toIso8601String(),
        'gender': currentState.gender,
        'wilaya': currentState.wilaya,
      });

      // Reload to confirm and reset editing state
      final newState = await _loadProfile();
      state =
          AsyncValue.data(newState.copyWith(isEditing: false, isSaving: false));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      // Restore previous state but stop saving
      state = AsyncValue.data(currentState.copyWith(isSaving: false));
      rethrow;
    }
  }
}

final userProfileControllerProvider =
    AsyncNotifierProvider<UserProfileController, UserProfileState>(() {
  return UserProfileController();
});
