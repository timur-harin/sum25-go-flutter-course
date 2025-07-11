import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> saveUserCredentials(String username, String password) async {
    await _storage.write(key: 'user_credentials', value: jsonEncode({'username': username, 'password': password}));
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final value = await _storage.read(key: 'user_credentials');
    if (value == null) {
      return {'username': null, 'password': null};
    }
    final map = jsonDecode(value) as Map<String, dynamic>;
    return {
      'username': map['username'] as String?,
      'password': map['password'] as String?,
    };
  }

  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'user_credentials');
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled ? 'true' : 'false');
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value == 'true';
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

  static Future<void> saveObject(String key, Map<String, dynamic> value) async {
    await _storage.write(key: key, value: jsonEncode(value));
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final value = await _storage.read(key: key);
    if (value == null) return null;
    return jsonDecode(value) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
