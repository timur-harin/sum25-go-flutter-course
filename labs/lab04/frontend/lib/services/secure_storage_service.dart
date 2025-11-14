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

  static Future<void> saveUserCredentials(
      String username, String password) async {
    await Future.wait([
      _storage.write(key: 'username', value: username),
      _storage.write(key: 'password', value: password),
    ]);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final credentials = await Future.wait([
      _storage.read(key: 'username'),
      _storage.read(key: 'password'),
    ]);
    return {
      'username': credentials[0],
      'password': credentials[1],
    };
  }

  static Future<void> deleteUserCredentials() async {
    await Future.wait([
      _storage.delete(key: 'username'),
      _storage.delete(key: 'password'),
    ]);
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: 'biometric_enabled', 
      value: enabled.toString(),
    );
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
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

  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
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
