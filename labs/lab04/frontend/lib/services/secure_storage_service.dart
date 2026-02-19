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

  static const _keyAuthToken = 'auth_token';
  static const _keyUsername = 'username';
  static const _keyPassword = 'password';
  static const _keyBiometricEnabled = 'biometric_enabled';

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  static Future<void> saveUserCredentials(String username, String password) async {
    await _storage.write(key: _keyUsername, value: username);
    await _storage.write(key: _keyPassword, value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: _keyUsername);
    final password = await _storage.read(key: _keyPassword);
    return {'username': username, 'password': password};
  }

  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: _keyUsername);
    await _storage.delete(key: _keyPassword);
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _keyBiometricEnabled, value: enabled ? 'true' : 'false');
  }

  static Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _keyBiometricEnabled);
    if (val == null) return false;
    return val.toLowerCase() == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> containsKey(String key) async {
    final allKeys = await _storage.readAll();
    return allKeys.containsKey(key);
  }

  static Future<List<String>> getAllKeys() async {
    final allKeys = await _storage.readAll();
    return allKeys.keys.toList();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
