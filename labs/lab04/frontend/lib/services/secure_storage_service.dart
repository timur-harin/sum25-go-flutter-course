import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  /// Secure storage instance with platform-specific encryption options
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Saves the authentication token securely using the key 'auth_token'
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Retrieves the saved authentication token, returns null if not found
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Deletes the stored authentication token
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Saves user credentials (username and password) securely
  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  /// Retrieves stored username and password as a Map
  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'username': await _storage.read(key: 'username'),
      'password': await _storage.read(key: 'password'),
    };
  }

  /// Deletes stored username and password credentials
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  /// Saves the biometric authentication enabled setting as a string
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  /// Checks if biometric authentication is enabled, defaults to false
  static Future<bool> isBiometricEnabled() async {
    String? enabledString = await _storage.read(key: 'biometric_enabled');
    return enabledString == 'true';
  }

  /// Saves any string data with a custom key
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Retrieves string data by key, returns null if not found
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  /// Deletes data stored with the specified key
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  /// Saves a Map object as JSON string in secure storage
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = json.encode(object);
    await _storage.write(key: key, value: jsonString);
  }

  /// Retrieves and parses a stored JSON object, returns null if not found
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);

    if (jsonString == null) {
      return null;
    }

    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Checks if a key exists in secure storage
  static Future<bool> containsKey(String key) async {
    final value = await _storage.read(key: key);
    return value != null;
  }

  /// Returns a list of all stored keys
  static Future<List<String>> getAllKeys() async {
    final allData = await _storage.readAll();
    return allData.keys.toList();
  }

  /// Deletes all data from secure storage
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Exports all stored key-value pairs (use with caution - defeats security purpose)
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
