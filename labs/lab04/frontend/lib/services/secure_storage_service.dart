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

  // Save authentication token securely
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Get authentication token from secure storage
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Delete authentication token from secure storage
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Save user credentials securely
  static Future<void> saveUserCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  // Get user credentials from secure storage
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password,
    };
  }

  // Delete user credentials from secure storage
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  // Save biometric setting securely
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  // Get biometric setting from secure storage
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  // Save any secure data with custom key
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Get secure data by key
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Delete secure data by key
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // Save object as JSON string in secure storage
  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  // Get object from secure storage
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Check if key exists in secure storage
  static Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  // Get all keys from secure storage
  static Future<List<String>> getAllKeys() async {
    final allData = await _storage.readAll();
    return allData.keys.toList();
  }

  // Clear all data from secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Export all data (for backup purposes)
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
