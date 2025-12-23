import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:maouidi/auth/base_auth_user_provider.dart';
import 'package:maouidi/auth/supabase_auth/supabase_auth_manager.dart';

// --- Global Accessors for Legacy UI ---

/// Get the current logged-in user (Legacy Bridge)
BaseAuthUser? get currentUser {
  final user = Supabase.instance.client.auth.currentUser;
  if (user == null) return null;
  return AuthUserInfo(
    uid: user.id,
    email: user.email ?? '',
    phoneNumber: user.phone,
  );
}

/// Helper to access the ID safely
String get currentUserId => currentUser?.uid ?? '';

/// Helper to check login status
bool get loggedIn => currentUser != null;

/// Helper to get email
String get currentUserEmail => currentUser?.email ?? '';

/// Helper to get phone
String get currentUserPhoneNumber => currentUser?.phoneNumber ?? '';

// --- Auth Actions ---

/// Sign out action
Future<void> signOut() async {
  await SupabaseAuthManager().signOut(null);
  // Pass context as null if not available, Manager should handle it safely
}

/// Sign in action
Future<BaseAuthUser?> signInWithEmail(
  BuildContext context,
  String email,
  String password,
) async {
  return await SupabaseAuthManager().signInWithEmail(context, email, password);
}

/// Sign up action
Future<BaseAuthUser?> createAccountWithEmail(
  BuildContext context,
  String email,
  String password,
) async {
  return await SupabaseAuthManager()
      .createAccountWithEmail(context, email, password);
}
