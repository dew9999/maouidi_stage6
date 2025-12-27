// lib/features/receipts/providers/receipt_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/receipt_service.dart';

part 'receipt_providers.g.dart';

/// Provider for receipt service
@riverpod
ReceiptService receiptService(ReceiptServiceRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ReceiptService(supabase);
}

/// Provider for receipt data
@riverpod
Future<Map<String, dynamic>?> receiptData(
  ReceiptDataRef ref,
  String requestId,
) async {
  final service = ref.watch(receiptServiceProvider);
  return await service.getReceipt(requestId);
}
