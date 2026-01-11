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

  // TODO: Implement saveAuthToken method
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // TODO: Implement getAuthToken method
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // TODO: Implement deleteAuthToken method
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // TODO: Implement saveUserCredentials method
  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  // TODO: Implement getUserCredentials method
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {'username': username, 'password': password};
  }

  // TODO: Implement deleteUserCredentials method
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  // TODO: Implement saveBiometricEnabled method
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  // TODO: Implement isBiometricEnabled method
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    return value?.toLowerCase() == 'true';
  }

  // TODO: Implement saveSecureData method
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // TODO: Implement getSecureData method
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // TODO: Implement deleteSecureData method
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // TODO: Implement saveObject method
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  // TODO: Implement getObject method
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // TODO: Implement containsKey method
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // TODO: Implement getAllKeys method
  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  // TODO: Implement clearAll method
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // TODO: Implement exportData method
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
