// lib/features/payments/providers/payment_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/chargily_service.dart';
import '../data/refund_service.dart';

part 'payment_providers.g.dart';

/// Provider for Chargily public key from Supabase config
/// NOTE: Secret key is NOT accessible from Flutter (security!)
/// Secret key is only available to Edge Functions via service role
@riverpod
Future<String> chargilyPublicKey(ChargilyPublicKeyRef ref) async {
  final supabase = ref.watch(supabaseClientProvider);

  // RLS policy ensures we can only see non-secret config
  final result = await supabase
      .from('app_config')
      .select('value')
      .eq('key', 'chargily_public_key')
      .single();

  return result['value'] as String;
}

/// Provider for Chargily service (calls Edge Functions)
/// SECURE: All payments go through Edge Functions, secret key never exposed
@riverpod
Future<ChargilyService> chargilyService(ChargilyServiceRef ref) async {
  final supabase = ref.watch(supabaseClientProvider);

  // Get Supabase URL from environment or use default
  const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '', // Will be set in .env or build args
  );

  // Get anon key from environment (public key, safe to use client-side)
  const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '', // Will be set in .env or build args
  );

  // Service now calls Edge Functions instead of Chargily directly
  return ChargilyService(
    supabaseUrl: supabaseUrl,
    supabaseAnonKey: supabaseAnonKey.isEmpty
        ? supabase.headers['apikey'] ?? ''
        : supabaseAnonKey,
  );
}

/// Provider for refund service
/// NOTE: Refunds should also be processed via Edge Function for security
@riverpod
Future<RefundService> refundService(RefundServiceRef ref) async {
  final supabase = ref.watch(supabaseClientProvider);
  final chargilyService = await ref.watch(chargilyServiceProvider.future);

  return RefundService(supabase, chargilyService);
}
