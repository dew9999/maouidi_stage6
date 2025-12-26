// lib/features/auth/presentation/user_role_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_repository.dart';
import 'auth_state_provider.dart';

part 'user_role_provider.g.dart';

/// FutureProvider that reactively fetches the user's role.
///
/// Automatically refreshes when auth state changes.
/// Returns null if user is not authenticated.
///
/// Role values:
/// - 'Medical Partner' - User exists in medical_partners table
/// - 'Patient' - User exists only in users table
/// - null - User is not authenticated
@riverpod
Future<String?> userRole(UserRoleRef ref) async {
  // Watch auth state future directly - this will cause the provider to rebuild when auth changes
  final user = await ref.watch(authStateProvider.future);

  if (user == null) return null;

  final repository = ref.watch(authRepositoryProvider);
  return await repository.getUserRole(user.id);
}
