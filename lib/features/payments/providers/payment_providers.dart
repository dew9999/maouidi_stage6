// lib/features/payments/providers/payment_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
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

/// Provider for Chargily service
/// IMPORTANT: This is for CLIENT-SIDE operations only (viewing checkout)
/// Payment creation should be done via Supabase Edge Function for security
@riverpod
Future<ChargilyService> chargilyService(ChargilyServiceRef ref) async {
  final publicKey = await ref.watch(chargilyPublicKeyProvider.future);

  // Secret key will be accessed from Edge Function
  // Using empty string here as it's only needed for server-side operations
  return ChargilyService(
    publicKey: publicKey,
    secretKey: '', // Not used client-side
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
