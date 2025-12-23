// lib/core/providers/supabase_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// Provides access to the Supabase client instance.
///
/// This is the single source of truth for accessing Supabase throughout the app.
/// Replaces the legacy SupaFlow singleton pattern.
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}
