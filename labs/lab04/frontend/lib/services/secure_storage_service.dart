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
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      return token;
    }
    return null;
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password
    };
  }

  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final isBiometricEnabled = await _storage.read(key: 'biometric_enabled');
    return isBiometricEnabled == 'true';
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
    if (jsonString != null) {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    }
    return null;
  }

  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    List<String> allKeys = [];
    final mapOfAllKeys = await _storage.readAll();
    mapOfAllKeys.forEach((key, _) {
      allKeys.add(key);
    });
    return allKeys;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
