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

  // Сохраняет токен аутентификации
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Получает токен аутентификации
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Удаляет токен аутентификации
  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // Сохраняет учетные данные пользователя
  static Future<void> saveUserCredentials(
      String username, String password) async {
    await _storage.write(key: 'username', value: username);
    await _storage.write(key: 'password', value: password);
  }

  // Получает учетные данные пользователя
  static Future<Map<String, String?>> getUserCredentials() async {
    final username = await _storage.read(key: 'username');
    final password = await _storage.read(key: 'password');
    return {
      'username': username,
      'password': password,
    };
  }

  // Удаляет учетные данные пользователя
  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: 'username');
    await _storage.delete(key: 'password');
  }

  // Сохраняет настройку биометрии
  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }

  // Проверяет, включена ли биометрия
  static Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: 'biometric_enabled');
    if (value == null) return false;
    return value.toLowerCase() == 'true';
  }

  // Сохраняет любые данные по ключу
  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Получает данные по ключу
  static Future<String?> getSecureData(String key) async {
    return await _storage.read(key: key);
  }

  // Удаляет данные по ключу
  static Future<void> deleteSecureData(String key) async {
    await _storage.delete(key: key);
  }

  // Сохраняет объект как JSON-строку
  static Future<void> saveObject(
      String key, Map<String, dynamic> object) async {
    final jsonString = jsonEncode(object);
    await _storage.write(key: key, value: jsonString);
  }

  // Получает объект по ключу
  static Future<Map<String, dynamic>?> getObject(String key) async {
    final jsonString = await _storage.read(key: key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  // Проверяет наличие ключа
  static Future<bool> containsKey(String key) async {
    return await _storage.containsKey(key: key);
  }

  // Получает все ключи
  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  // Очищает все данные
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Экспортирует все данные (для резервного копирования)
  static Future<Map<String, String>> exportData() async {
    return await _storage.readAll();
  }
}
