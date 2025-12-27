// lib/features/homecare_service/providers/service_providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/providers/supabase_provider.dart';
import '../data/service_repository.dart';

part 'service_providers.g.dart';

/// Provider for service repository
@riverpod
ServiceRepository serviceRepository(ServiceRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ServiceRepository(supabase);
}

/// Provider for service status of a specific request
@riverpod
Future<Map<String, dynamic>> serviceStatus(
  ServiceStatusRef ref,
  String requestId,
) async {
  final repository = ref.watch(serviceRepositoryProvider);
  return await repository.getServiceStatus(requestId: requestId);
}
