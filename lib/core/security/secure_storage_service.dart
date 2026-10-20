import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:neram_pos/core/errors/app_exception.dart';

/// Secure hardware-backed encrypted storage for credentials, tokens, and keys.
class SecureStorageService {
  SecureStorageService({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(resetOnError: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock,
            ),
          );

  final FlutterSecureStorage _storage;

  /// Reads a secure value by [key].
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw SecureStorageException(
        message: 'Failed to read key: $key from secure storage: $e',
      );
    }
  }

  /// Writes a secure [value] associated with [key].
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw SecureStorageException(
        message: 'Failed to write key: $key to secure storage: $e',
      );
    }
  }

  /// Deletes a key from secure storage.
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw SecureStorageException(
        message: 'Failed to delete key: $key from secure storage: $e',
      );
    }
  }

  /// Clears all keys from secure storage (e.g. on staff logout).
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      throw SecureStorageException(
        message: 'Failed to clear secure storage: $e',
      );
    }
  }

  /// Checks if a key exists in secure storage.
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      throw SecureStorageException(
        message: 'Failed to check key: $key in secure storage: $e',
      );
    }
  }
}
