// lib/core/services/app_config_service.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app_config_service.g.dart';

/// Service for managing application configuration from database
///
/// Loads configuration values from app_config table with caching
class AppConfigService {
  final SupabaseClient _supabase;

  // Cache for config values
  final Map<String, dynamic> _cache = {};
  DateTime? _lastCacheUpdate;

  // Cache duration: 5 minutes
  static const _cacheDuration = Duration(minutes: 5);

  AppConfigService(this._supabase);

  /// Get platform fee in DZD
  ///
  /// Returns the platform fee from app_config table.
  /// Falls back to 500.0 DZD if not configured or on error.
  Future<double> getPlatformFee() async {
    try {
      // Check if cache is valid
      if (_isCacheValid() && _cache.containsKey('platform_fee_dzd')) {
        return (_cache['platform_fee_dzd'] as num).toDouble();
      }

      // Fetch from database
      final result = await _supabase
          .from('app_config')
          .select('value')
          .eq('key', 'platform_fee_dzd')
          .maybeSingle();

      if (result != null && result['value'] != null) {
        final value = double.tryParse(result['value'].toString()) ?? 500.0;

        // Update cache
        _cache['platform_fee_dzd'] = value;
        _lastCacheUpdate = DateTime.now();

        return value;
      }

      // No config found, return default
      return 500.0;
    } catch (e) {
      // On error, return default value
      return 500.0;
    }
  }

  /// Get any config value by key
  ///
  /// Generic method to fetch any configuration value
  Future<String?> getConfig(String key) async {
    try {
      // Check cache first
      if (_isCacheValid() && _cache.containsKey(key)) {
        return _cache[key]?.toString();
      }

      // Fetch from database
      final result = await _supabase
          .from('app_config')
          .select('value')
          .eq('key', key)
          .maybeSingle();

      if (result != null && result['value'] != null) {
        final value = result['value'].toString();

        // Update cache
        _cache[key] = value;
        _lastCacheUpdate = DateTime.now();

        return value;
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Clear the cache
  void clearCache() {
    _cache.clear();
    _lastCacheUpdate = null;
  }

  /// Check if cache is still valid
  bool _isCacheValid() {
    if (_lastCacheUpdate == null) return false;

    final now = DateTime.now();
    final difference = now.difference(_lastCacheUpdate!);

    return difference < _cacheDuration;
  }
}

/// Provider for AppConfigService
@riverpod
AppConfigService appConfigService(AppConfigServiceRef ref) {
  final supabase = Supabase.instance.client;
  return AppConfigService(supabase);
}

/// Provider for platform fee (cached)
///
/// This provider automatically fetches and caches the platform fee
@riverpod
Future<double> platformFee(PlatformFeeRef ref) async {
  final configService = ref.watch(appConfigServiceProvider);
  return await configService.getPlatformFee();
}
