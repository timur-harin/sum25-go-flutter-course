import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static final Map<String, String> _testStorage = {};
  static bool _isTestEnvironment = false;

  static void enableTestMode() {
    _isTestEnvironment = true;
  }

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static Future<void> _write(String key, String? value) async {
    if (_isTestEnvironment) {
      if (value == null) {
        _testStorage.remove(key);
      } else {
        _testStorage[key] = value;
      }
    } else {
      if (value == null) {
        await _storage.delete(key: key);
      } else {
        await _storage.write(key: key, value: value);
      }
    }
  }

  static Future<String?> _read(String key) async {
    return _isTestEnvironment
        ? _testStorage[key]
        : await _storage.read(key: key);
  }

  static Future<bool> _containsKey(String key) async {
    return _isTestEnvironment
        ? _testStorage.containsKey(key)
        : await _storage.containsKey(key: key);
  }

  static Future<Map<String, String>> _readAll() async {
    return _isTestEnvironment
        ? Map.from(_testStorage)
        : await _storage.readAll();
  }

  static Future<void> _deleteAll() async {
    if (_isTestEnvironment) {
      _testStorage.clear();
    } else {
      await _storage.deleteAll();
    }
  }

  static Future<void> saveAuthToken(String token) async =>
      await _write('auth_token', token);

  static Future<String?> getAuthToken() async => await _read('auth_token');

  static Future<void> deleteAuthToken() async =>
      await _write('auth_token', null);

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
    await _write('username', null);
    await _write('password', null);
  }

  static Future<void> saveBiometricEnabled(bool enabled) async =>
      await _write('biometric_enabled', enabled.toString());

  static Future<bool> isBiometricEnabled() async {
    final value = await _read('biometric_enabled');
    return value == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async =>
      await _write(key, value);

  static Future<String?> getSecureData(String key) async => await _read(key);

  static Future<void> deleteSecureData(String key) async =>
      await _write(key, null);

  static Future<void> saveObject(
          String key, Map<String, dynamic> object) async =>
      await _write(key, json.encode(object));

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _read(key);
    return jsonString != null ? json.decode(jsonString) : null;
  }

  static Future<bool> containsKey(String key) async => await _containsKey(key);

  static Future<List<String>> getAllKeys() async {
    final all = await _readAll();
    return all.keys.toList();
  }

  static Future<void> clearAll() async => await _deleteAll();

  static Future<Map<String, String>> exportData() async => await _readAll();
}
