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

  static Future<void> saveAuthToken(String token) async {
    await _write(key: 'auth_token', value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _read(key: 'auth_token');
  }

  static Future<void> deleteAuthToken() async {
    await _delete(key: 'auth_token');
  }

  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _write(key: 'username', value: username);
    await _write(key: 'password', value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _read(key: 'username');
    final password = await _read(key: 'password');
    return {'username': username, 'password': password};
  }

  static Future<void> deleteUserCredentials() async {
    await _delete(key: 'username');
    await _delete(key: 'password');
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async {
    await _write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _delete(key: key);
  }

  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _write(key: key, value: jsonString);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _read(key: key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString);
  }

  static Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } on MissingPluginException {
      return _inMemory.containsKey(key);
    }
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
