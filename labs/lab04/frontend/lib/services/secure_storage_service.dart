import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static final Map<String, String?> _inMemory = {};

  static Future<void> _write({required String key, String? value}) async {
    try {
      if (value == null) {
        await _delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    } on MissingPluginException {
      if (value == null) {
        _inMemory.remove(key);
      } else {
        _inMemory[key] = value;
      }
    }
  }

  static Future<String?> _read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _inMemory[key];
    }
  }

  static Future<void> _delete({required String key}) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      _inMemory.remove(key);
    }
  }

  static Future<Map<String, String>> _readAll() async {
    try {
      return await _storage.readAll();
    } on MissingPluginException {
      return Map<String, String>.from(_inMemory);
    }
  }

  static Future<void> _deleteAll() async {
    try {
      await _storage.deleteAll();
    } on MissingPluginException {
      _inMemory.clear();
    }
  }

  // TODO: Implement saveAuthToken method
  static Future<void> saveAuthToken(String token) async {
    // TODO: Save authentication token securely
    // Use key 'auth_token'
    await _write(key: 'auth_token', value: token);
  }

  // TODO: Implement getAuthToken method
  static Future<String?> getAuthToken() async {
    // TODO: Get authentication token from secure storage
    // Return null if not found
    return await _read(key: 'auth_token');
  }

  // TODO: Implement deleteAuthToken method
  static Future<void> deleteAuthToken() async {
    // TODO: Delete authentication token from secure storage
    await _delete(key: 'auth_token');
  }

  // TODO: Implement saveUserCredentials method
  static Future<void> saveUserCredentials(
      String username, String password) async {
    // TODO: Save user credentials securely
    // Save username with key 'username' and password with key 'password'
    await _write(key: 'username', value: username);
    await _write(key: 'password', value: password);
  }

  // TODO: Implement getUserCredentials method
  static Future<Map<String, String?>> getUserCredentials() async {
    // TODO: Get user credentials from secure storage
    // Return map with 'username' and 'password' keys
    final username = await _read(key: 'username');
    final password = await _read(key: 'password');
    return {'username': username, 'password': password};
  }

  // TODO: Implement deleteUserCredentials method
  static Future<void> deleteUserCredentials() async {
    // TODO: Delete user credentials from secure storage
    // Delete both username and password
    await _delete(key: 'username');
    await _delete(key: 'password');
  }

  // TODO: Implement saveBiometricEnabled method
  static Future<void> saveBiometricEnabled(bool enabled) async {
    // TODO: Save biometric setting securely
    // Convert bool to string for storage
    await _write(key: 'biometric_enabled', value: enabled.toString());
  }

  // TODO: Implement isBiometricEnabled method
  static Future<bool> isBiometricEnabled() async {
    // TODO: Get biometric setting from secure storage
    // Return false as default if not found
    final value = await _read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  // TODO: Implement saveSecureData method
  static Future<void> saveSecureData(String key, String value) async {
    // TODO: Save any secure data with custom key
    await _write(key: key, value: value);
  }

  // TODO: Implement getSecureData method
  static Future<String?> getSecureData(String key) async {
    // TODO: Get secure data by key
    return await _read(key: key);
  }

  // TODO: Implement deleteSecureData method
  static Future<void> deleteSecureData(String key) async {
    // TODO: Delete secure data by key
    await _delete(key: key);
  }

  // TODO: Implement saveObject method
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    // TODO: Save object as JSON string in secure storage
    // Convert object to JSON string first
    final jsonString = jsonEncode(object);
    await _write(key: key, value: jsonString);
  }

  // TODO: Implement getObject method
  static Future<Map<String, dynamic>?> getObject(String key) async {
    // TODO: Get object from secure storage
    // Parse JSON string back to Map
    final jsonString = await _read(key: key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  // TODO: Implement containsKey method
  static Future<bool> containsKey(String key) async {
    // TODO: Check if key exists in secure storage
    try {
      return await _storage.containsKey(key: key);
    } on MissingPluginException {
      return _inMemory.containsKey(key);
    }
  }

  // TODO: Implement getAllKeys method
  static Future<List<String>> getAllKeys() async {
    // TODO: Get all keys from secure storage
    // Return list of all stored keys
    final all = await _readAll();
    return all.keys.toList();
  }

  // TODO: Implement clearAll method
  static Future<void> clearAll() async {
    // TODO: Clear all data from secure storage
    // Use deleteAll method from FlutterSecureStorage
    await _deleteAll();
  }

  // TODO: Implement exportData method
  static Future<Map<String, String>> exportData() async {
    // TODO: Export all data (for backup purposes)
    // Return all key-value pairs
    // NOTE: This defeats the purpose of secure storage, use carefully
    return await _readAll();
  }
}
