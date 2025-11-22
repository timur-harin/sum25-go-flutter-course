import 'package:flutter/services.dart';
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

  // In-memory fallback for tests when plugin is absent
  static final Map<String, String?> _inMemory = {};

  // Helper to write a value (plugin or fallback)
  static Future<void> _write(String key, String? value) async {
    try {
      if (value == null) {
        await _storage.delete(key: key);
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

  // Helper to read a value
  static Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _inMemory[key];
    }
  }

  // Helper to delete a single key
  static Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      _inMemory.remove(key);
    }
  }

  // Helper to read all key-value pairs
  static Future<Map<String, String>> _readAll() async {
    try {
      return await _storage.readAll();
    } on MissingPluginException {
      return Map<String, String>.from(_inMemory);
    }
  }

  // Helper to delete all keys
  static Future<void> _deleteAll() async {
    try {
      await _storage.deleteAll();
    } on MissingPluginException {
      _inMemory.clear();
    }
  }

  // Save authentication token
  static Future<void> saveAuthToken(String token) =>
      _write('auth_token', token);

  // Get authentication token
  static Future<String?> getAuthToken() => _read('auth_token');

  // Delete authentication token
  static Future<void> deleteAuthToken() => _delete('auth_token');

  // Save user credentials
  static Future<void> saveUserCredentials(
          String username, String password) async =>
      Future.wait([
        _write('username', username),
        _write('password', password),
      ]);

  // Get user credentials
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _read('username');
    final password = await _read('password');
    return {
      'username': username,
      'password': password,
    };
  }

  // Delete user credentials
  static Future<void> deleteUserCredentials() => Future.wait([
        _delete('username'),
        _delete('password'),
      ]);

  // Save biometric setting
  static Future<void> saveBiometricEnabled(bool enabled) =>
      _write('biometric_enabled', enabled.toString());

  // Get biometric setting
  static Future<bool> isBiometricEnabled() async {
    final val = await _read('biometric_enabled');
    return val?.toLowerCase() == 'true';
  }

  // Save generic secure data
  static Future<void> saveSecureData(String key, String value) =>
      _write(key, value);

  // Get secure data by key
  static Future<String?> getSecureData(String key) => _read(key);

  // Delete secure data by key
  static Future<void> deleteSecureData(String key) => _delete(key);

  // Save object as JSON
  static Future<void> saveObject(
          String key, Map<String, dynamic> object) async =>
      _write(key, jsonEncode(object));

  // Get object from JSON
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _read(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } on MissingPluginException {
      return _inMemory.containsKey(key);
    }
  }

  // Get all keys
  static Future<List<String>> getAllKeys() async {
    final all = await _readAll();
    return all.keys.toList();
  }

  // Clear all data
  static Future<void> clearAll() => _deleteAll();

  // Export all data (for backup)
  static Future<Map<String, String>> exportData() => _readAll();
}
