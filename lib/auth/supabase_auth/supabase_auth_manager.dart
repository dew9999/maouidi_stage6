import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/base_auth_user_provider.dart';
// Imports our new clean auth utils

class SupabaseAuthManager {
  // Singleton instance
  static final SupabaseAuthManager _instance = SupabaseAuthManager._internal();
  factory SupabaseAuthManager() => _instance;
  SupabaseAuthManager._internal();

  // Helper to get the client
  SupabaseClient get _client => Supabase.instance.client;

  // Stream of auth state changes
  Stream<BaseAuthUser?> get authStateChanges =>
      _client.auth.onAuthStateChange.map(
        (data) => _createAuthUser(data.session?.user),
      );

  // Current user accessor
  BaseAuthUser? get user => _createAuthUser(_client.auth.currentUser);

  // Internal helper to map Supabase User to our BaseAuthUser
  BaseAuthUser? _createAuthUser(User? user) {
    if (user == null) return null;
    return AuthUserInfo(
      uid: user.id,
      email: user.email ?? '',
      phoneNumber: user.phone,
    );
  }

  // --- Auth Actions ---

  Future<BaseAuthUser?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return _createAuthUser(response.user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign in failed: $e')),
      );
      return null;
    }
  }

  Future<BaseAuthUser?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return _createAuthUser(response.user);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
      );
      return null;
    }
  }

  Future<void> signOut(BuildContext? context) async {
    await _client.auth.signOut();
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      // Note: Delete requires admin/backend logic usually, but here is the client call
      // await _client.functions.invoke('deleteUser');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contact support to delete account')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Delete failed: $e')),
      );
    }
  }

  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Reset failed: $e')),
      );
    }
  }
}
