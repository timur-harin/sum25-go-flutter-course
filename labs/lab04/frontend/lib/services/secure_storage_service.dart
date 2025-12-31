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

  /// Save authentication token securely under 'auth_token' key.
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Retrieve authentication token, or null if not found.
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Delete the stored authentication token.
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Save user credentials (username & password).
  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  /// Retrieve user credentials as a map with 'username' and 'password'.
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password,
    };
  }

  /// Delete stored user credentials.
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  /// Save biometric-enabled flag ('true'/'false').
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: 'biometric_enabled',
      value: enabled.toString(),
    );
  }

  /// Retrieve biometric-enabled flag, defaulting to false if not set.
  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: 'biometric_enabled');
    return val == 'true';
  }

  /// Save any secure data under a custom key.
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Retrieve secure data by key.
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete secure data by key.
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  /// Save a JSON-serializable object under a custom key.
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = json.encode(object);
    await _storage.write(key: key, value: jsonString);
  }

  /// Retrieve an object stored as JSON string under a custom key.
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    final decoded = json.decode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    return null;
  }

  /// Check if a given key exists in secure storage.
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Get all keys stored in secure storage.
  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  /// Delete all entries from secure storage.
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Export all key-value pairs from secure storage.
  /// Use with caution: exposes all stored secrets.
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
