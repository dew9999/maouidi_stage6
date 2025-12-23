// lib/core/providers/secure_storage_provider.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_provider.g.dart';

/// Provides a secure storage instance configured for maximum security
/// Uses platform-native keychains (iOS Keychain, Android Keystore)
@riverpod
FlutterSecureStorage secureStorage(SecureStorageRef ref) {
  // Configure platform-specific security options
  const androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm:
        KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );

  const iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  return const FlutterSecureStorage(
    aOptions: androidOptions,
    iOptions: iosOptions,
  );
}

/// Example helper methods for common secure storage operations
/// Usage: ref.read(secureStorageHelperProvider).saveToken(token);
@riverpod
SecureStorageHelper secureStorageHelper(SecureStorageHelperRef ref) {
  return SecureStorageHelper(ref.watch(secureStorageProvider));
}

class SecureStorageHelper {
  final FlutterSecureStorage _storage;

  SecureStorageHelper(this._storage);

  // Token storage (for session tokens, API keys, etc.)
  Future<void> saveToken(String key, String token) async {
    await _storage.write(key: key, value: token);
  }

  Future<String?> getToken(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> deleteToken(String key) async {
    await _storage.delete(key: key);
  }

  // Clear all secure storage (e.g., on logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Check if a key exists
  Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }
}
