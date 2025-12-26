// lib/features/auth/data/auth_repository.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';

part 'auth_repository.g.dart';

/// Repository for authentication operations.
///
/// Provides clean interface for auth operations and role management.
class AuthRepository {
  final SupabaseClient _supabase;

  AuthRepository(this._supabase);

  /// Sign in with email and password.
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Get the current authenticated user.
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Fetch the user's role by checking the users and medical_partners tables.
  ///
  /// Role determination logic:
  /// - If user exists in medical_partners table -> 'Medical Partner'
  /// - Otherwise -> 'Patient'
  ///
  /// Returns null if user is not authenticated or an error occurs.
  Future<String?> getUserRole(String userId) async {
    try {
      // Check if user exists in medical_partners table
      final partnerResponse = await _supabase
          .from('medical_partners')
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (partnerResponse != null) {
        return 'Medical Partner';
      }

      // User exists in auth but not in medical_partners, so they're a patient
      return 'Patient';
    } catch (e) {
      // On error, default to Patient role for safety
      return 'Patient';
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response =
        await _supabase.from('users').select().eq('id', userId).maybeSingle();
    return response;
  }

  Future<void> updateUserProfile(
    String userId,
    Map<String, dynamic> data,
  ) async {
    await _supabase.from('users').update(data).eq('id', userId);
  }
}

/// Provider for the AuthRepository.
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthRepository(supabase);
}
