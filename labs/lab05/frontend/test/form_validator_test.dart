import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_frontend/core/validation/form_validator.dart';

void main() {
  group('FormValidator Tests', () {
    group('validateEmail', () {
      test('should return null for valid email', () {
        final result = FormValidator.validateEmail('test@example.com');
        expect(result, isNull);
      });

      test('should return error for null email', () {
        final result = FormValidator.validateEmail(null);
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for empty email', () {
        final result = FormValidator.validateEmail('');
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for email without @', () {
        final result = FormValidator.validateEmail('testexample.com');
        expect(result, isNotNull);
        expect(result, contains('invalid'));
      });

      test('should return error for email without domain', () {
        final result = FormValidator.validateEmail('test@');
        expect(result, isNotNull);
        expect(result, contains('invalid'));
      });

      test('should return error for email that is too long', () {
        final longEmail = 'a' * 95 + '@example.com'; // > 100 characters
        final result = FormValidator.validateEmail(longEmail);
        expect(result, isNotNull);
        expect(result, contains('too long'));
      });
    });

    group('validatePassword', () {
      test('should return null for valid password', () {
        final result = FormValidator.validatePassword('abc123');
        expect(result, isNull);
      });

      test('should return error for null password', () {
        final result = FormValidator.validatePassword(null);
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for empty password', () {
        final result = FormValidator.validatePassword('');
        expect(result, isNotNull);
        expect(result, contains('required'));
      });

      test('should return error for password too short', () {
        final result = FormValidator.validatePassword('abc1');
        expect(result, isNotNull);
        expect(result, contains('6 characters'));
      });

      test('should return error for password without letters', () {
        final result = FormValidator.validatePassword('123456');
        expect(result, isNotNull);
        expect(result, contains('letter and number'));
      });

      test('should return error for password without numbers', () {
        final result = FormValidator.validatePassword('abcdef');
        expect(result, isNotNull);
        expect(result, contains('letter and number'));
      });
    });

    group('sanitizeText', () {
      test('should return cleaned text for normal input', () {
        final result = FormValidator.sanitizeText('Hello World');
        expect(result, equals('Hello World'));
      });

      test('should remove < and > characters', () {
        final result = FormValidator.sanitizeText('Hello <script> World');
        expect(result, equals('Hello  World'));
      });

      test('should trim whitespace', () {
        final result = FormValidator.sanitizeText('  Hello World  ');
        expect(result, equals('Hello World'));
      });

      test('should handle null input', () {
        final result = FormValidator.sanitizeText(null);
        expect(result, equals(''));
      });

      test('should handle empty input', () {
        final result = FormValidator.sanitizeText('');
        expect(result, equals(''));
      });
    });

    group('isValidLength', () {
      test('should return true for text within length limits', () {
        final result =
            FormValidator.isValidLength('Hello', minLength: 1, maxLength: 10);
        expect(result, isTrue);
      });

      test('should return false for text too short', () {
        final result =
            FormValidator.isValidLength('Hi', minLength: 5, maxLength: 10);
        expect(result, isFalse);
      });

      test('should return false for text too long', () {
        final result = FormValidator.isValidLength('Hello World!',
            minLength: 1, maxLength: 5);
        expect(result, isFalse);
      });

      test('should return false for null text', () {
        final result =
            FormValidator.isValidLength(null, minLength: 1, maxLength: 10);
        expect(result, isFalse);
      });

      test('should return true for text at exact boundaries', () {
        final result1 =
            FormValidator.isValidLength('Hello', minLength: 5, maxLength: 5);
        expect(result1, isTrue);

        final result2 =
            FormValidator.isValidLength('H', minLength: 1, maxLength: 5);
        expect(result2, isTrue);
      });
    });
  });
}
