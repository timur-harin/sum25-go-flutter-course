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

  // Implement saveAuthToken method
  static Future<void> saveAuthToken(String token) async {
    // Save authentication token securely
    // Use key 'auth_token'
    await _storage.write(key: 'auth_token', value: token);
  }

  // Implement getAuthToken method
  static Future<String?> getAuthToken() async {
    // Get authentication token from secure storage
    // Return null if not found
    return await _storage.read(key: 'auth_token');
  }

  // Implement deleteAuthToken method
  static Future<void> deleteAuthToken() async {
    // Delete authentication token from secure storage
    await _storage.delete(key: 'auth_token');
  }

  // Implement saveUserCredentials method
  static Future<void> saveUserCredentials(
      String username, String password) async {
    // Save user credentials securely
    // Save username with key 'username' and password with key 'password'
    await Future.wait([
      _storage.write(key: 'username', value: username),
      _storage.write(key: 'password', value: password),
    ]);
  }

  // Implement getUserCredentials method
  static Future<Map<String, String?>> getUserCredentials() async {
    // Get user credentials from secure storage
    // Return map with 'username' and 'password' keys
    final credentials = await Future.wait([
      _storage.read(key: 'username'),
      _storage.read(key: 'password'),
    ]);
    return {
      'username': credentials[0],
      'password': credentials[1],
    };
  }

  // Implement deleteUserCredentials method
  static Future<void> deleteUserCredentials() async {
    // Delete user credentials from secure storage
    // Delete both username and password
    await Future.wait([
      _storage.delete(key: 'username'),
      _storage.delete(key: 'password'),
    ]);
  }

  // Implement saveBiometricEnabled method
  static Future<void> saveBiometricEnabled(bool enabled) async {
    // Save biometric setting securely
    // Convert bool to string for storage
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  // Implement isBiometricEnabled method
  static Future<bool> isBiometricEnabled() async {
    // Get biometric setting from secure storage
    // Return false as default if not found
    final value = await _storage.read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  // Implement saveSecureData method
  static Future<void> saveSecureData(String key, String value) async {
    // Save any secure data with custom key
    await _storage.write(key: key, value: value);
  }

  // Implement getSecureData method
  static Future<String?> getSecureData(String key) async {
    // Get secure data by key
    return await _storage.read(key: key);
  }

  // Implement deleteSecureData method
  static Future<void> deleteSecureData(String key) async {
    // Delete secure data by key
    await _storage.delete(key: key);
  }

  // Implement saveObject method
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    // Save object as JSON string in secure storage
    // Convert object to JSON string first
    final jsonString = jsonEncode(object);
    await saveSecureData(key, jsonString);
  }

  // Implement getObject method
  static Future<Map<String, dynamic>?> getObject(String key) async {
    // Get object from secure storage
    // Parse JSON string back to Map
    final jsonString = await getSecureData(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Implement containsKey method
  static Future<bool> containsKey(String key) async {
    // Check if key exists in secure storage
    final allKeys = await _storage.readAll();
    return allKeys.containsKey(key);
  }

  // Implement getAllKeys method
  static Future<List<String>> getAllKeys() async {
    // Get all keys from secure storage
    // Return list of all stored keys
    final allData = await _storage.readAll();
    return allData.keys.toList();
  }

  // Implement clearAll method
  static Future<void> clearAll() async {
    // Clear all data from secure storage
    // Use deleteAll method from FlutterSecureStorage
    await _storage.deleteAll();
  }

  // Implement exportData method
  static Future<Map<String, String>> exportData() async {
    // Export all data (for backup purposes)
    // Return all key-value pairs
    // NOTE: This defeats the purpose of secure storage, use carefully
    return await _storage.readAll();
  }
}
