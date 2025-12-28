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

  // TODO: Implement saveAuthToken method
  static Future<void> saveAuthToken(String token) async {
    // TODO: Save authentication token securely
    // Use key 'auth_token'
    _storage.write(key: 'auth_token', value: token);
  }

  // TODO: Implement getAuthToken method
  static Future<String?> getAuthToken() async {
    // TODO: Get authentication token from secure storage
    return _storage.read(key: "auth_token");
  }

  // TODO: Implement deleteAuthToken method
  static Future<void> deleteAuthToken() async {
    // TODO: Delete authentication token from secure storage
    return _storage.delete(key: "auth_token");
  }

  // TODO: Implement saveUserCredentials method
  static Future<void> saveUserCredentials(
      String username, String password) async {
    // TODO: Save user credentials securely
    return _storage.write(
      key: 'user_credentials',
      value: json.encode({'username': username, 'password': password}),
    );
  }

  // TODO: Implement getUserCredentials method
  static Future<Map<String, String?>> getUserCredentials() async {
    // TODO: Get user credentials from secure storage
    return _storage.read(key: "user_credentials").then((value) {
      if (value != null) {
        final Map<String, dynamic> credentials =
            json.decode(value) as Map<String, dynamic>;
        return {
          'username': credentials['username'] as String?,
          'password': credentials['password'] as String?,
        };
      }
      return {'username': null, 'password': null};
    });
  }

  // TODO: Implement deleteUserCredentials method
  static Future<void> deleteUserCredentials() async {
    // TODO: Delete user credentials from secure storage
    return _storage.delete(key: "user_credentials");
  }

  // Save biometric setting securely
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  // Get biometric setting from secure storage
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
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
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = json.encode(object);
    await _storage.write(key: key, value: jsonString);
  }

  // Get object from secure storage
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  // Check if key exists in secure storage
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Get all keys from secure storage
  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
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
