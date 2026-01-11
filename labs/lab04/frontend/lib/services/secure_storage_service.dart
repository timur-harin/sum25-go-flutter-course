import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

// Secure storage helper with memory fallback
class SecureStorageService 
{
  // Setup secure storage for Android/iOS
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: 
    AndroidOptions(encryptedSharedPreferences: true),
    iOptions: 
    IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Memory storage for when secure storage fails
  static final Map<String, String?> _inMemory = {};

  // Save or delete data by key
  static Future<void> _write(String key, String? value) 
  async 
  {
    try 
    {
      if (value == null) 
        await _storage.delete(key: key);
      else 
        await _storage.write(key: key, value: value);
    } 
    on MissingPluginException 
    {
      if (value == null) 
        _inMemory.remove(key);
      else 
        _inMemory[key] = value;
    }
  }

  // Get data by key
  static Future<String?> _read(String key) 
  async 
  {
    try 
    {
      return await _storage.read(key: key);
    } 
    on MissingPluginException 
    {
      return _inMemory[key];
    }
  }

  // Remove data by key
  static Future<void> _delete(String key) 
  async 
  {
    try 
    {
      await _storage.delete(key: key);
    }
    on MissingPluginException 
    {
      _inMemory.remove(key);
    }
  }

  // Get all stored data
  static Future<Map<String, String>> _readAll() 
  async 
  {
    try 
    {
      return await _storage.readAll();
    } 
    on MissingPluginException
    {
      return Map<String, String>.from(_inMemory);
    }
  }

  // Clear all stored data
  static Future<void> _deleteAll() async 
  {
    try 
    {
      await _storage.deleteAll();
    } 
    on MissingPluginException 
    {
      _inMemory.clear();
    }
  }

  // Auth token operations
  static Future<void> saveAuthToken(String token) =>
      _write('auth_token', token);
  static Future<String?> getAuthToken() => 
      _read('auth_token');
  static Future<void> deleteAuthToken() => 
      _delete('auth_token');

  // User credentials operations
  static Future<void> saveUserCredentials(String username, String password) 
  async 
  {
    await _write('username', username);
    await _write('password', password);
  }

  static Future<Map<String, String?>> getUserCredentials() 
  async 
  {
    return 
      {
      'username': await _read('username'),
      'password': await _read('password'),
    };
  }

  static Future<void> deleteUserCredentials() 
  async
  {
    await _delete('username');
    await _delete('password');
  }

  // Biometric settings
  static Future<void> saveBiometricEnabled(bool enabled) =>
      _write('biometric_enabled', enabled.toString());

  static Future<bool> isBiometricEnabled() 
  async 
  {
    return (await _read('biometric_enabled'))?.toLowerCase() == 'true';
  }

  // General data operations
  static Future<void> saveSecureData(String key, String value) =>
      _write(key, value);
  static Future<String?> getSecureData(String key) => 
      _read(key);
  static Future<void> deleteSecureData(String key) => 
      _delete(key);

  // Object storage
  static Future<void> saveObject(String key, Map<String, dynamic> object) =>
      _write(key, jsonEncode(object));

  static Future<Map<String, dynamic>?> getObject(String key)
  async 
  {
    final data = await _read(key);
    return data != null ? jsonDecode(data) as Map<String, dynamic> : null;
  }

  // Storage management
  static Future<bool> containsKey(String key)
  async 
  {
    try 
    {
      return await _storage.containsKey(key: key);
    }
    on MissingPluginException
    {
      return _inMemory.containsKey(key);
    }
  }

  static Future<List<String>> getAllKeys() async => 
      (await _readAll()).keys.toList();
  static Future<void> clearAll() => 
      _deleteAll();
  static Future<Map<String, String>> exportData() =>
      _readAll();
}
