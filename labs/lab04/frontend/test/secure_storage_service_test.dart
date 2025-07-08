import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lab04_frontend/services/secure_storage_service.dart';

void main() {
  // Initialize Flutter bindings for platform channels
  TestWidgetsFlutterBinding.ensureInitialized(); 

  group('SecureStorageService Tests', () {
    setUp(() async {
      // Clear secure storage before each test
      await SecureStorageService.clearAll();
    });

    tearDown(() async {
      // Clean up after each test
      await SecureStorageService.clearAll();
    });

    test('should save and get auth token', () async {
      const token = 'test_auth_token_12345';

      await SecureStorageService.saveAuthToken(token);
      final retrievedToken = await SecureStorageService.getAuthToken();

      expect(retrievedToken, equals(token));
    });

    test('should return null for non-existent auth token', () async {
      final token = await SecureStorageService.getAuthToken();
      expect(token, isNull);
    });

    test('should delete auth token', () async {
      const token = 'token_to_delete';

      await SecureStorageService.saveAuthToken(token);
      expect(await SecureStorageService.getAuthToken(), equals(token));

      await SecureStorageService.deleteAuthToken();
      expect(await SecureStorageService.getAuthToken(), isNull);
    });

    test('should save and get user credentials', () async {
      const username = 'test_user';
      const password = 'secure_password_123';

      await SecureStorageService.saveUserCredentials(username, password);
      final credentials = await SecureStorageService.getUserCredentials();

      expect(credentials['username'], equals(username));
      expect(credentials['password'], equals(password));
    });

    test('should return null credentials when not set', () async {
      final credentials = await SecureStorageService.getUserCredentials();
      expect(credentials['username'], isNull);
      expect(credentials['password'], isNull);
    });

    test('should delete user credentials', () async {
      const username = 'user_to_delete';
      const password = 'password_to_delete';

      await SecureStorageService.saveUserCredentials(username, password);
      expect((await SecureStorageService.getUserCredentials())['username'],
          equals(username));

      await SecureStorageService.deleteUserCredentials();
      final credentials = await SecureStorageService.getUserCredentials();
      expect(credentials['username'], isNull);
      expect(credentials['password'], isNull);
    });

    test('should save and get biometric enabled setting', () async {
      await SecureStorageService.saveBiometricEnabled(true);
      expect(await SecureStorageService.isBiometricEnabled(), isTrue);

      await SecureStorageService.saveBiometricEnabled(false);
      expect(await SecureStorageService.isBiometricEnabled(), isFalse);
    });

    test('should return false for biometric setting when not set', () async {
      final isEnabled = await SecureStorageService.isBiometricEnabled();
      expect(isEnabled, isFalse);
    });

    test('should save and get secure data with custom key', () async {
      const key = 'custom_secure_key';
      const value = 'very_secret_data';

      await SecureStorageService.saveSecureData(key, value);
      final retrievedValue = await SecureStorageService.getSecureData(key);

      expect(retrievedValue, equals(value));
    });

    test('should return null for non-existent secure data', () async {
      final value =
          await SecureStorageService.getSecureData('non_existent_key');
      expect(value, isNull);
    });

    test('should delete secure data by key', () async {
      const key = 'key_to_delete';
      const value = 'value_to_delete';

      await SecureStorageService.saveSecureData(key, value);
      expect(await SecureStorageService.getSecureData(key), equals(value));

      await SecureStorageService.deleteSecureData(key);
      expect(await SecureStorageService.getSecureData(key), isNull);
    });

    test('should save and get object data', () async {
      const key = 'user_profile';
      final objectData = {
        'id': 123,
        'name': 'John Doe',
        'preferences': {
          'theme': 'dark',
          'notifications': true,
        },
        'roles': ['user', 'admin'],
      };

      await SecureStorageService.saveObject(key, objectData);
      final retrievedObject = await SecureStorageService.getObject(key);

      expect(retrievedObject, equals(objectData));
    });

    test('should return null for non-existent object', () async {
      final object =
          await SecureStorageService.getObject('non_existent_object');
      expect(object, isNull);
    });

    test('should check if key exists', () async {
      const key = 'existence_test_key';
      const value = 'test_value';

      expect(await SecureStorageService.containsKey(key), isFalse);

      await SecureStorageService.saveSecureData(key, value);
      expect(await SecureStorageService.containsKey(key), isTrue);
    });

    test('should get all keys', () async {
      final testData = {
        'key1': 'value1',
        'key2': 'value2',
        'key3': 'value3',
      };

      for (final entry in testData.entries) {
        await SecureStorageService.saveSecureData(entry.key, entry.value);
      }

      final allKeys = await SecureStorageService.getAllKeys();
      for (final key in testData.keys) {
        expect(allKeys.contains(key), isTrue);
      }
    });

    test('should clear all data', () async {
      await SecureStorageService.saveAuthToken('test_token');
      await SecureStorageService.saveUserCredentials('user', 'pass');
      await SecureStorageService.saveSecureData('key', 'value');

      final keysBeforeClear = await SecureStorageService.getAllKeys();
      expect(keysBeforeClear.length, greaterThan(0));

      await SecureStorageService.clearAll();

      final keysAfterClear = await SecureStorageService.getAllKeys();
      expect(keysAfterClear, isEmpty);
    });

    test('should export all data', () async {
      final testData = {
        'auth_token': 'token123',
        'username': 'testuser',
        'password': 'testpass',
        'custom_key': 'custom_value',
      };

      for (final entry in testData.entries) {
        await SecureStorageService.saveSecureData(entry.key, entry.value);
      }

      final exportedData = await SecureStorageService.exportData();

      for (final entry in testData.entries) {
        expect(exportedData[entry.key], equals(entry.value));
      }
    });

    test('should handle complex object serialization', () async {
      const key = 'complex_settings';
      final complexObject = {
        'user': {
          'id': 456,
          'profile': {
            'firstName': 'Jane',
            'lastName': 'Smith',
            'avatar': null,
          },
          'settings': {
            'privacy': {
              'showEmail': false,
              'showPhone': true,
            },
            'notifications': {
              'email': true,
              'push': false,
              'sms': true,
            },
          },
          'tags': ['premium', 'verified'],
        },
        'app': {
          'version': '1.0.0',
          'lastLogin': '2025-01-09T12:00:00Z',
          'sessionTimeout': 3600,
        },
      };

      await SecureStorageService.saveObject(key, complexObject);
      final retrievedObject = await SecureStorageService.getObject(key);

      expect(retrievedObject, equals(complexObject));
    });

    test('should handle empty and null values', () async {
      await SecureStorageService.saveSecureData('empty_string', '');
      final emptyValue =
          await SecureStorageService.getSecureData('empty_string');
      expect(emptyValue, equals(''));

      final nullObject = await SecureStorageService.getObject('null_object');
      expect(nullObject, isNull);
    });
  });
}
