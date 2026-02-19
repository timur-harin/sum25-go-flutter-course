import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

/// Service for managing encrypted secure storage
/// Perfect for storing sensitive data like tokens, passwords, and personal information
/// Uses platform-specific secure storage (Keychain on iOS, Keystore on Android)
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Saves authentication token securely
  /// Use this for storing JWT tokens or API keys
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Retrieves the stored authentication token
  /// Returns null if no token is stored
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Removes the authentication token from secure storage
  /// Call this when user logs out
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Saves user login credentials securely
  /// Stores username and password separately for better security
  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  /// Retrieves stored user credentials
  /// Returns a map with username and password keys (values may be null)
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password,
    };
  }

  /// Removes stored user credentials
  /// Deletes both username and password
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  /// Saves biometric authentication preference
  /// Stores whether user has enabled biometric login
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  /// Checks if biometric authentication is enabled
  /// Returns false by default if no setting is stored
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
  }

  /// Saves any secure data with a custom key
  /// Generic method for storing sensitive string data
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Retrieves secure data by key
  /// Returns null if key doesn't exist
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  /// Removes secure data by key
  /// Permanently deletes the specified key-value pair
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  /// Saves a complex object as encrypted JSON
  /// The object must be serializable to JSON
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  /// Retrieves a complex object from encrypted JSON
  /// Returns null if key doesn't exist or JSON parsing fails
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Checks if a key exists in secure storage
  /// Returns true if the key exists, false otherwise
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  /// Returns all keys currently stored in secure storage
  /// Useful for debugging and data management
  static Future<List<String>> getAllKeys() async {
    final allData = await _storage.readAll();
    return allData.keys.toList();
  }

  /// Removes all data from secure storage
  /// Use with extreme caution - this will delete all stored data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  /// Exports all data for backup purposes
  /// WARNING: This defeats the purpose of secure storage
  /// Only use for debugging or authorized data export
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
