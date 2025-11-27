import 'dart:convert';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  // Storage plugin (real device / emulator)
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions:
        IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  // Backup storage (used in unit tests where the plugin is not present)
  static final Map<String, String> _inMemory = <String, String>{};

  //necessary functions
  static Future<void> _write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on MissingPluginException {
      _inMemory[key] = value;
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

  //Аuth token
  static const _kAuthToken = 'auth_token';

  static Future<void> saveAuthToken(String token) =>
      _write(_kAuthToken, token);

  static Future<String?> getAuthToken() => _read(_kAuthToken);

  static Future<void> deleteAuthToken() => _delete(_kAuthToken);

  //user credentials
  static const _kUsername = 'username';
  static const _kPassword = 'password';

  static Future<void> saveUserCredentials(
    String username, String password) async {
    await _write(_kUsername, username);
    await _write(_kPassword, password);
  }

  static Future<Map<String, String?>> getUserCredentials() async => {
        'username': await _read(_kUsername),
        'password': await _read(_kPassword),
      };

  static Future<void> deleteUserCredentials() async {
    await _delete(_kUsername);
    await _delete(_kPassword);
  }

  //biometric flag
  static const _kBiometric = 'biometric_enabled';

  static Future<void> saveBiometricEnabled(bool enabled) =>
      _write(_kBiometric, enabled.toString());

  static Future<bool> isBiometricEnabled() async =>
      (await _read(_kBiometric)) == 'true';

  //Arbitrary secure data
  static Future<void> saveSecureData(String key, String value) =>
      _write(key, value);

  static Future<String?> getSecureData(String key) => _read(key);

  static Future<void> deleteSecureData(String key) => _delete(key);

  // JSON objects 
  static Future<void> saveObject(String key, Map<String, dynamic> object) =>
      _write(key, jsonEncode(object));

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final raw = await _read(key);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  //Utility
  static Future<bool> containsKey(String key) async =>
      (await _read(key)) != null;

  static Future<List<String>> getAllKeys() async =>
      (await _readAll()).keys.toList();

  static Future<void> clearAll() => _deleteAll();

  static Future<Map<String, String>> exportData() => _readAll();
}
