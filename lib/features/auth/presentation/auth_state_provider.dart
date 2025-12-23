// lib/features/auth/presentation/auth_state_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';

part 'auth_state_provider.g.dart';

/// Stream provider that watches authentication state changes.
///
/// Emits the current User whenever auth state changes (login, logout, etc.).
/// Replaces the legacy maouidiSupabaseUserStream().
@riverpod
Stream<User?> authState(AuthStateRef ref) {
  final supabase = ref.watch(supabaseClientProvider);

  return supabase.auth.onAuthStateChange.map((authState) {
    return authState.session?.user;
  });
}

/// Provider for checking if user is logged in.
///
/// Derived from authState for convenience.
@riverpod
Future<bool> isLoggedIn(IsLoggedInRef ref) async {
  final user = await ref.watch(authStateProvider.future);
  return user != null;
}
