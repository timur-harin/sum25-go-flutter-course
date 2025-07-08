import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  static Future saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future saveUserCredentials(String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  static Future deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  static Future saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    if (value == null) return false;
    return value.toLowerCase() == 'true';
  }

  static Future saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  static Future deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  static Future saveObject(String key, Map object) async {
    await _storage.write(key: key, value: jsonEncode(object));
  }

  static Future<Map?> getObject(String key) async {
    final str = await _storage.read(key: key);
    if (str == null) return null;
    return jsonDecode(str);
  }

  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  static Future clearAll() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
