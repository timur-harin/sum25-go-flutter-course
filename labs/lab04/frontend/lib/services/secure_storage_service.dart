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
    await _storage.write(key: 'auth_token', value: token);
  }

  // TODO: Implement getAuthToken method
  static Future<String?> getAuthToken() async {
    // TODO: Get authentication token from secure storage
    // Return null if not found
    return await _storage.read(key: 'auth_token');
  }

  // TODO: Implement deleteAuthToken method
  static Future<void> deleteAuthToken() async {
    // TODO: Delete authentication token from secure storage
    await _storage.delete(key: 'auth_token');
  }

  // TODO: Implement saveUserCredentials method
  static Future<void> saveUserCredentials(
      String username, String password) async {
    // TODO: Save user credentials securely
    // Save username with key 'username' and password with key 'password'
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  // TODO: Implement getUserCredentials method
  static Future<Map<String, String?>> getUserCredentials() async {
    // TODO: Get user credentials from secure storage
    // Return map with 'username' and 'password' keys
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  // TODO: Implement deleteUserCredentials method
  static Future<void> deleteUserCredentials() async {
    // TODO: Delete user credentials from secure storage
    // Delete both username and password
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  // TODO: Implement saveBiometricEnabled method
  static Future<void> saveBiometricEnabled(bool enabled) async {
    // TODO: Save biometric setting securely
    // Convert bool to string for storage
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  // TODO: Implement isBiometricEnabled method
  static Future<bool> isBiometricEnabled() async {
    // TODO: Get biometric setting from secure storage
    // Return false as default if not found
    final String? value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  // TODO: Implement saveSecureData method
  static Future<void> saveSecureData(String key, String value) async {
    // TODO: Save any secure data with custom key
    await _storage.write(key: key, value: value);
  }

  // TODO: Implement getSecureData method
  static Future<String?> getSecureData(String key) async {
    // TODO: Get secure data by key
    return await _storage.read(key: key);
  }

  // TODO: Implement deleteSecureData method
  static Future<void> deleteSecureData(String key) async {
    // TODO: Delete secure data by key
    await _storage.delete(key: key);
  }

  // TODO: Implement saveObject method
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    // TODO: Save object as JSON string in secure storage
    // Convert object to JSON string first
    final String jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  // TODO: Implement getObject method
  static Future<Map<String, dynamic>?> getObject(String key) async {
    // TODO: Get object from secure storage
    // Parse JSON string back to Map
    final String? jsonString = await _storage.read(key: key);
    if (jsonString == null) {
      return null;
    }
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // TODO: Implement containsKey method
  static Future<bool> containsKey(String key) async {
    // TODO: Check if key exists in secure storage
    return await _storage.containsKey(key: key);
  }

  // TODO: Implement getAllKeys method
  static Future<List<String>> getAllKeys() async {
    // TODO: Get all keys from secure storage
    // Return list of all stored keys
    final Map<String, String> allData = await _storage.readAll();
    return allData.keys.toList();
  }

  // TODO: Implement clearAll method
  static Future<void> clearAll() async {
    // TODO: Clear all data from secure storage
    // Use deleteAll method from FlutterSecureStorage
    await _storage.deleteAll();
  }

  // TODO: Implement exportData method
  static Future<Map<String, String>> exportData() async {
    // TODO: Export all data (for backup purposes)
    // Return all key-value pairs
    return await _storage.readAll();
  }
}