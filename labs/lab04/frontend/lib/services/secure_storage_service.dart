import 'dart:convert';


class SecureStorageService {
  static final Map<String, String> _store = <String, String>{};

  static const _kAuthToken = 'auth_token';
  static const _kUsername = 'username';
  static const _kPassword = 'password';
  static const _kBiometric = 'biometric_enabled';

  static Future<void> saveAuthToken(String token) async {
    _store[_kAuthToken] = token;
  }

  static Future<String?> getAuthToken() async => _store[_kAuthToken];
  static Future<void> deleteAuthToken() async => _store.remove(_kAuthToken);

  static Future<void> saveUserCredentials(String username, String password) async {
    _store[_kUsername] = username;
    _store[_kPassword] = password;
  }

  static Future<Map<String, String?>> getUserCredentials() async => {
        'username': _store[_kUsername],
        'password': _store[_kPassword],
      };

  static Future<void> deleteUserCredentials() async {
    _store.remove(_kUsername);
    _store.remove(_kPassword);
  }


  static Future<void> saveBiometricEnabled(bool enabled) async {
    _store[_kBiometric] = enabled.toString();
  }

  static Future<bool> isBiometricEnabled() async => _store[_kBiometric] == 'true';

  static Future<void> saveSecureData(String key, String value) async {
    _store[key] = value;
  }

  static Future<String?> getSecureData(String key) async => _store[key];
  static Future<void> deleteSecureData(String key) async => _store.remove(key);

  static Future<void> saveObject(String key, Map<String, dynamic> object) async {
    _store[key] = jsonEncode(object);
  }

  static Future<Map<String, dynamic>?> getObject(String key) async {
    final raw = _store[key];
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }


  static Future<bool> containsKey(String key) async => _store.containsKey(key);
  static Future<List<String>> getAllKeys() async => _store.keys.toList();

  static Future<void> clearAll() async => _store.clear();
  static Future<Map<String, String>> exportData() async => Map.of(_store);
}