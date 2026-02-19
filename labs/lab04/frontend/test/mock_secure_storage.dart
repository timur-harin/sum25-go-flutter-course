import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';

class MockSecureStorage extends FlutterSecureStoragePlatform {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    String? value,
    Map<String, String>? options,
  }) async {
    if (value == null) {
      _storage.remove(key);
    } else {
      _storage[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    Map<String, String>? options,
  }) async {
    return _storage[key];
  }

  @override
  Future<bool> containsKey({
    required String key,
    Map<String, String>? options,
  }) async {
    return _storage.containsKey(key);
  }

  @override
  Future<void> delete({
    required String key,
    Map<String, String>? options,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    Map<String, String>? options,
  }) async {
    return Map.from(_storage);
  }

  @override
  Future<void> deleteAll({
    Map<String, String>? options,
  }) async {
    _storage.clear();
  }
}
