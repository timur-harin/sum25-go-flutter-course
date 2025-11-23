import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';
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

  static bool _inMemory = false;
  static final Map<String, String> _memoryStore = {};

  static Future<void> _write(String key, String value) async {
    if (_inMemory) {
      _memoryStore[key] = value;
      return;
    }
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      _inMemory = true;
      _memoryStore[key] = value;
    }
  }

  static Future<String?> _read(String key) async {
    if (_inMemory) return _memoryStore[key];
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      _inMemory = true;
      return _memoryStore[key];
    }
  }

  static Future<void> _delete(String key) async {
    if (_inMemory) {
      _memoryStore.remove(key);
      return;
    }
    try {
      await _storage.delete(key: key);
    } on MissingPluginException {
      _inMemory = true;
      _memoryStore.remove(key);
    }
  }

  static Future<Map<String, String>> _readAll() async {
    if (_inMemory) return Map<String, String>.from(_memoryStore);
    try {
      return await _storage.readAll();
    } on MissingPluginException {
      _inMemory = true;
      return Map<String, String>.from(_memoryStore);
    }
  }

  static Future<void> _deleteAll() async {
    if (_inMemory) {
      _memoryStore.clear();
      return;
    }
    try {
      await _storage.deleteAll();
    } on MissingPluginException {
      _inMemory = true;
      _memoryStore.clear();
    }
  }

  static Future<bool> _containsKey(String key) async {
    if (_inMemory) return _memoryStore.containsKey(key);
    try {
      return await _storage.containsKey(key: key);
    } on MissingPluginException {
      _inMemory = true;
      return _memoryStore.containsKey(key);
    }
  }

  static Future<void> saveAuthToken(String token) async {
    await _write('auth_token', token);
  }

  static Future<String?> getAuthToken() async {
    return await _read('auth_token');
  }

  static Future<void> deleteAuthToken() async {
    await _delete('auth_token');
  }

  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _write('username', username);
    await _write('password', password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _read('username');
    final password = await _read('password');
    return {'username': username, 'password': password};
  }

  static Future<void> deleteUserCredentials() async {
    await _delete('username');
    await _delete('password');
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _write('biometric_enabled', enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _read('biometric_enabled');
    if (val == null) return false;
    return val.toLowerCase() == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async {
    await _write(key, value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _read(key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _delete(key);
  }

  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _write(key, jsonString);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final value = await _read(key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    return await _containsKey(key);
  }

  static Future<List<String>> getAllKeys() async {
    final all = await _readAll();
    return all.keys.toList();
  }

  static Future<void> clearAll() async {
    await _deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return await _readAll();
  }
}
