import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lab04_frontend/services/preferences_service.dart';

void main() {
  group('PreferencesService Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
      await PreferencesService.init();
    });

    test('should initialize SharedPreferences', () async {
      expect(() => PreferencesService.init(), returnsNormally);
    });

    test('should set and get string values', () async {
      const key = 'test_string';
      const value = 'Hello World';

      await PreferencesService.setString(key, value);
      final result = PreferencesService.getString(key);

      expect(result, equals(value));
    });

    test('should return null for non-existent string key', () {
      const key = 'non_existent_key';
      final result = PreferencesService.getString(key);
      expect(result, isNull);
    });

    test('should set and get int values', () async {
      const key = 'test_int';
      const value = 42;

      await PreferencesService.setInt(key, value);
      final result = PreferencesService.getInt(key);

      expect(result, equals(value));
    });

    test('should return null for non-existent int key', () {
      const key = 'non_existent_int';
      final result = PreferencesService.getInt(key);
      expect(result, isNull);
    });

    test('should set and get bool values', () async {
      const key = 'test_bool';
      const value = true;

      await PreferencesService.setBool(key, value);
      final result = PreferencesService.getBool(key);

      expect(result, equals(value));
    });

    test('should set and get string list values', () async {
      const key = 'test_string_list';
      const value = ['item1', 'item2', 'item3'];

      await PreferencesService.setStringList(key, value);
      final result = PreferencesService.getStringList(key);

      expect(result, equals(value));
    });

    test('should set and get object values', () async {
      const key = 'test_object';
      const value = {
        'name': 'John Doe',
        'age': 30,
        'isActive': true,
      };

      await PreferencesService.setObject(key, value);
      final result = PreferencesService.getObject(key);

      expect(result, equals(value));
    });

    test('should return null for non-existent object key', () {
      const key = 'non_existent_object';
      final result = PreferencesService.getObject(key);
      expect(result, isNull);
    });

    test('should remove specific key', () async {
      const key = 'test_remove';
      const value = 'value_to_remove';

      await PreferencesService.setString(key, value);
      expect(PreferencesService.getString(key), equals(value));

      await PreferencesService.remove(key);
      expect(PreferencesService.getString(key), isNull);
    });

    test('should check if key exists', () async {
      const key = 'test_contains';
      const value = 'test_value';

      expect(PreferencesService.containsKey(key), isFalse);

      await PreferencesService.setString(key, value);
      expect(PreferencesService.containsKey(key), isTrue);
    });

    test('should get all keys', () async {
      const keys = ['key1', 'key2', 'key3'];
      const values = ['value1', 'value2', 'value3'];

      for (int i = 0; i < keys.length; i++) {
        await PreferencesService.setString(keys[i], values[i]);
      }

      final allKeys = PreferencesService.getAllKeys();
      for (final key in keys) {
        expect(allKeys.contains(key), isTrue);
      }
    });

    test('should clear all preferences', () async {
      await PreferencesService.setString('key1', 'value1');
      await PreferencesService.setInt('key2', 42);
      await PreferencesService.setBool('key3', true);

      expect(PreferencesService.getAllKeys().length, greaterThan(0));

      await PreferencesService.clear();
      expect(PreferencesService.getAllKeys().length, equals(0));
    });

    test('should handle complex object serialization', () async {
      const key = 'complex_object';
      final value = {
        'user': {
          'id': 123,
          'name': 'Jane Doe',
          'preferences': {
            'theme': 'dark',
            'notifications': true,
          },
          'tags': ['developer', 'flutter', 'dart'],
        },
        'timestamp': '2025-01-09T12:00:00Z',
      };

      await PreferencesService.setObject(key, value);
      final result = PreferencesService.getObject(key);

      expect(result, equals(value));
    });
  });
}
