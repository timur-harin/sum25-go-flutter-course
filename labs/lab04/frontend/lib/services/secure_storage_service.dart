import 'dart:convert';
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

  static const String _authTokenKey = 'auth_token';
  static const String _usernameKey = 'username';
  static const String _passwordKey = 'password';
  static const String _biometricKey = 'biometric_enabled';

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _authTokenKey);
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  static Future<void> saveUserCredentials(
      String username, String password) async {
    await Future.wait([
      _storage.write(key: _usernameKey, value: username),
      _storage.write(key: _passwordKey, value: password),
    ]);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: _usernameKey);
    final password = await _storage.read(key: _passwordKey);
    return {'username': username, 'password': password};
  }

  static Future<void> deleteUserCredentials() async {
    await Future.wait([
      _storage.delete(key: _usernameKey),
      _storage.delete(key: _passwordKey),
    ]);
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled ? 'true' : 'false');
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricKey);
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

  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      final Map<String, dynamic> map = jsonDecode(jsonString);
      return map;
    } catch (_) {
      return null;
    }
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
    final allData = await _storage.readAll();
    return allData;
  }
}
