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
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final user = await _storage.read(key: 'username');
    final pass = await _storage.read(key: 'password');
    return {'username': user, 'password': pass};
  }

  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final s = await _storage.read(key: 'biometric_enabled');
    return s == 'true';
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
    await _storage.write(key: key, value: jsonEncode(object));
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final s = await _storage.read(key: key);
    if (s == null) return null;
    return jsonDecode(s) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    final keys = await _storage.readAll();
    return keys.containsKey(key);
  }

  static Future<List<String>> getAllKeys() async {
    final keys = await _storage.readAll();
    return keys.keys.toList();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}