import 'dart:convert';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions:
        IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  static final Map<String, String> _inMemory = <String, String>{};

  static Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      if (e is MissingPluginException) {
        _inMemory[key] = value;
      } else {
        rethrow;
      }
    }
  }

  static Future<String?> _read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      if (e is MissingPluginException) {
        return _inMemory[key];
      }
      return null;
    }
  }

  static Future<void> _delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      if (e is MissingPluginException) {
        _inMemory.remove(key);
      }
    }
  }

  static Future<Map<String, String>> _readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      if (e is MissingPluginException) {
        return Map.from(_inMemory);
      }
      return {};
    }
  }

  static Future<void> _deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      if (e is MissingPluginException) {
        _inMemory.clear();
      }
    }
  }

  static const _kAuthToken = 'auth_token';

  static Future<void> saveAuthToken(String token) =>
      _write(_kAuthToken, token);

  static Future<String?> getAuthToken() => _read(_kAuthToken);

  static Future<void> deleteAuthToken() => _delete(_kAuthToken);

  static const _kUsername = 'username';
  static const _kPassword = 'password';

  static Future<void> saveUserCredentials(
    String username, String password) async {
    await _write(_kUsername, username);
    await _write(_kPassword, password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    return {
      'username': await _read(_kUsername),
      'password': await _read(_kPassword),
    };
  }

  static Future<void> deleteUserCredentials() async {
    await _delete(_kUsername);
    await _delete(_kPassword);
  }

  static const _kBiometric = 'biometric_enabled';

  static Future<void> saveBiometricEnabled(bool enabled) =>
      _write(_kBiometric, enabled.toString());

  static Future<bool> isBiometricEnabled() async {
    final value = await _read(_kBiometric);
    return value == 'true';
  }

  static Future<void> saveSecureData(String key, String value) =>
      _write(key, value);

  static Future<String?> getSecureData(String key) => _read(key);

  static Future<void> deleteSecureData(String key) => _delete(key);

  static Future<void> saveObject(String key, Map<String, dynamic> object) =>
      _write(key, jsonEncode(object));

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final data = await _read(key);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    final value = await _read(key);
    return value != null;
  }

  static Future<List<String>> getAllKeys() async {
    final allData = await _readAll();
    return allData.keys.toList();
  }

  static Future<void> clearAll() => _deleteAll();

  static Future<Map<String, String>> exportData() => _readAll();
}