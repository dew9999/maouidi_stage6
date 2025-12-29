// lib/features/homecare_service/presentation/service_tracking_controller.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../providers/service_providers.dart';

part 'service_tracking_controller.g.dart';

/// Controller for service tracking actions
@riverpod
class ServiceTrackingController extends _$ServiceTrackingController {
  @override
  FutureOr<void> build() {}

  /// Partner marks service as started
  Future<void> markStarted(String requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(serviceRepositoryProvider);
      await repository.markServiceStarted(appointmentId: requestId);

      // Refresh service status
      ref.invalidate(serviceStatusProvider(requestId));
    });
  }

  /// Partner marks service as completed
  Future<void> markCompleted(String requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(serviceRepositoryProvider);
      await repository.markServiceCompleted(appointmentId: requestId);

      // Refresh service status
      ref.invalidate(serviceStatusProvider(requestId));
    });
  }

  /// Patient confirms service received
  Future<void> confirmReceived(String requestId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(serviceRepositoryProvider);
      await repository.confirmServiceReceived(appointmentId: requestId);

      // Refresh service status
      ref.invalidate(serviceStatusProvider(requestId));
    });
  }

  /// Cancel service
  Future<void> cancelService({
    required String requestId,
    required String cancelledBy,
    required String reason,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(serviceRepositoryProvider);
      await repository.cancelService(
        appointmentId: requestId,
        cancelledBy: cancelledBy,
        reason: reason,
      );

      // Refresh service status
      ref.invalidate(serviceStatusProvider(requestId));
    });
  }
}
