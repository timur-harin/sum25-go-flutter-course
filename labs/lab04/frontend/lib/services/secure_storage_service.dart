import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  static Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } on MissingPluginException {
      return _inMemory[key];
    }
  }

  static Future<void> _delete(String key) async {
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

  static Future<void> saveAuthToken(String token) =>
      _write('auth_token', token);

  static Future<String?> getAuthToken() => _read('auth_token');

  static Future<void> deleteAuthToken() => _delete('auth_token');

  static Future<void> saveUserCredentials(
          String username, String password) async =>
      Future.wait([
        _write('username', username),
        _write('password', password),
      ]);

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _read('username');
    final password = await _read('password');
    return {
      'username': username,
      'password': password,
    };
  }

  static Future<void> deleteUserCredentials() => Future.wait([
        _delete('username'),
        _delete('password'),
      ]);

  static Future<void> saveBiometricEnabled(bool enabled) =>
      _write('biometric_enabled', enabled.toString());

  static Future<bool> isBiometricEnabled() async {
    final val = await _read('biometric_enabled');
    return val?.toLowerCase() == 'true';
  }

  static Future<void> saveSecureData(String key, String value) =>
      _write(key, value);

  static Future<String?> getSecureData(String key) => _read(key);

  static Future<void> deleteSecureData(String key) => _delete(key);

  static Future<void> saveObject(
          String key, Map<String, dynamic> object) async =>
      _write(key, jsonEncode(object));

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _read(key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
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

  static Future<void> clearAll() => _deleteAll();

  static Future<Map<String, String>> exportData() => _readAll();
}
