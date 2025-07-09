import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Save the authentication token securely with key 'auth_token'.
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Get the authentication token, returns null if not found.
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Delete the authentication token.
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Save user credentials: username and password.
  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  /// Get user credentials, returns map with keys 'username' and 'password'.
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password,
    };
  }

  /// Delete user credentials.
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  /// Save biometric enabled flag as string 'true'/'false'.
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  /// Get biometric enabled flag, defaults to false if missing.
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  /// Save any secure data with a custom key.
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Get secure data by key.
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete secure data by key.
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  /// Save object as JSON string with given key.
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = json.encode(object);
    await _storage.write(key: key, value: jsonString);
  }

  /// Get object from JSON string, returns null if not found or invalid.
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      final map = json.decode(jsonString);
      if (map is Map<String, dynamic>) {
        return map;
      }
    } catch (_) {
      // Invalid JSON or decoding error.
    }
    return null;
  }

  /// Check if a key exists in secure storage.
  static Future<bool> containsKey(String key) async {
    final allKeys = await _storage.readAll();
    return allKeys.containsKey(key);
  }

  /// Get all keys stored in secure storage.
  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  /// Clear all data from secure storage.
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Export all data (map of all key-value pairs).
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }

  /// Delete multiple keys in batch.
  static Future<void> deleteMultipleKeys(List<String> keys) async {
    final all = await _storage.readAll();
    for (final key in keys) {
      if (all.containsKey(key)) {
        await _storage.delete(key: key);
      }
    }
  }
}
