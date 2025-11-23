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

  // Auth token
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // User credentials
  static Future<void> saveUserCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password,
    };
  }

  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  // Biometric enabled setting
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  // Generic secure key-value storage
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // Save and retrieve objects (as JSON)
  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonStr = jsonEncode(object);
    await _storage.write(key: key, value: jsonStr);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonStr = await _storage.read(key: key);
    if (jsonStr == null) return null;

    try {
      return jsonDecode(jsonStr);
    } catch (_) {
      return null;
    }
  }

  // Key management
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Export all key-value pairs
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
