import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Общий интерфейс для хранилища
abstract class _Storage {
  Future<void> write({required String key, required String? value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<bool> containsKey({required String key});
  Future<Map<String, String>> readAll();
  Future<void> deleteAll();
}

/// Обёртка над реальным FlutterSecureStorage
class _RealStorage implements _Storage {
  final FlutterSecureStorage _inner = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  @override
  Future<void> write({required String key, required String? value}) =>
      _inner.write(key: key, value: value);

  @override
  Future<String?> read({required String key}) =>
      _inner.read(key: key);

  @override
  Future<void> delete({required String key}) =>
      _inner.delete(key: key);

  @override
  Future<bool> containsKey({required String key}) =>
      _inner.containsKey(key: key);

  @override
  Future<Map<String, String>> readAll() =>
      _inner.readAll();

  @override
  Future<void> deleteAll() =>
      _inner.deleteAll();
}

/// In-memory «фейковое» хранилище для тестов
class _FakeStorage implements _Storage {
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String? value}) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = value;
    }
  }

  @override
  Future<String?> read({required String key}) async => _store[key];

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async =>
      _store.containsKey(key);

  @override
  Future<Map<String, String>> readAll() async =>
      Map<String, String>.from(_store);

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }
}

/// Сервис, который при тестах автоматически берёт _FakeStorage,
/// а в продакшне — реальное FlutterSecureStorage.
class SecureStorageService {
  static final _Storage _storage = Platform.environment.containsKey('FLUTTER_TEST')
      ? _FakeStorage()
      : _RealStorage();

  static const _authTokenKey = 'auth_token';
  static const _usernameKey = 'username';
  static const _passwordKey = 'password';
  static const _biometricKey = 'biometric_enabled';

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _authTokenKey, value: token);
  }

  static Future<String?> getAuthToken() async {
    return _storage.read(key: _authTokenKey);
  }

  static Future<void> deleteAuthToken() async {
    await _storage.delete(key: _authTokenKey);
  }

  static Future<void> saveUserCredentials(String username, String password) async {
    await _storage.write(key: _usernameKey, value: username);
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final user = await _storage.read(key: _usernameKey);
    final pass = await _storage.read(key: _passwordKey);
    return {'username': user, 'password': pass};
  }

  static Future<void> deleteUserCredentials() async {
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _passwordKey);
  }

  static Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  static Future<bool> isBiometricEnabled() async {
    final v = await _storage.read(key: _biometricKey);
    return v == 'true';
  }

  static Future<void> saveSecureData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return _storage.read(key: key);
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
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  static Future<bool> containsKey(String key) async {
    return _storage.containsKey(key: key);
  }

  static Future<List<String>> getAllKeys() async {
    final all = await _storage.readAll();
    return all.keys.toList();
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  static Future<Map<String, String>> exportData() async {
    return _storage.readAll();
  }
}
