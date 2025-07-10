import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_frontend/domain/entities/user.dart';

void main() {
  group('User Entity Tests', () {
    final testUser = User(
      id: 1,
      name: 'John Doe',
      email: 'john@example.com',
      createdAt: DateTime(2025, 1, 1),
    );

    group('Constructor and Properties', () {
      test('should create user with all properties', () {
        expect(testUser.id, equals(1));
        expect(testUser.name, equals('John Doe'));
        expect(testUser.email, equals('john@example.com'));
        expect(testUser.createdAt, equals(DateTime(2025, 1, 1)));
      });
    });

    group('Equatable Implementation', () {
      test('should be equal when all properties are the same', () {
        final user1 = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        final user2 = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(user1, equals(user2));
        expect(user1.hashCode, equals(user2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final user1 = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        final user2 = User(
          id: 2,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(user1, isNot(equals(user2)));
      });

      test('should have proper props implementation', () {
        expect(testUser.props, isA<List<Object>>());
        expect(testUser.props.length, equals(4));
        expect(testUser.props, contains(1));
        expect(testUser.props, contains('John Doe'));
        expect(testUser.props, contains('john@example.com'));
        expect(testUser.props, contains(DateTime(2025, 1, 1)));
      });
    });

    group('CopyWith Method', () {
      test('should create new instance with updated id', () {
        final updatedUser = testUser.copyWith(id: 2);

        expect(updatedUser.id, equals(2));
        expect(updatedUser.name, equals(testUser.name));
        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.createdAt, equals(testUser.createdAt));
        expect(updatedUser, isNot(same(testUser)));
      });

      test('should create new instance with updated name', () {
        final updatedUser = testUser.copyWith(name: 'Jane Smith');

        expect(updatedUser.id, equals(testUser.id));
        expect(updatedUser.name, equals('Jane Smith'));
        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.createdAt, equals(testUser.createdAt));
      });

      test('should create new instance with updated email', () {
        final updatedUser = testUser.copyWith(email: 'jane@example.com');

        expect(updatedUser.id, equals(testUser.id));
        expect(updatedUser.name, equals(testUser.name));
        expect(updatedUser.email, equals('jane@example.com'));
        expect(updatedUser.createdAt, equals(testUser.createdAt));
      });

      test('should create new instance with updated createdAt', () {
        final newDate = DateTime(2025, 2, 1);
        final updatedUser = testUser.copyWith(createdAt: newDate);

        expect(updatedUser.id, equals(testUser.id));
        expect(updatedUser.name, equals(testUser.name));
        expect(updatedUser.email, equals(testUser.email));
        expect(updatedUser.createdAt, equals(newDate));
      });

      test('should create identical instance when no parameters provided', () {
        final copiedUser = testUser.copyWith();

        expect(copiedUser, equals(testUser));
        expect(copiedUser, isNot(same(testUser)));
      });

      test('should handle multiple field updates', () {
        final updatedUser = testUser.copyWith(
          id: 3,
          name: 'Bob Wilson',
          email: 'bob@example.com',
        );

        expect(updatedUser.id, equals(3));
        expect(updatedUser.name, equals('Bob Wilson'));
        expect(updatedUser.email, equals('bob@example.com'));
        expect(updatedUser.createdAt, equals(testUser.createdAt));
      });
    });

    group('Email Validation', () {
      test('should validate correct email formats', () {
        final validEmails = [
          User(
              id: 1,
              name: 'Test',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: 'user123@domain.co.uk',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: 'firstname.lastname@example.org',
              createdAt: DateTime(2025, 1, 1)),
        ];

        for (final user in validEmails) {
          expect(user.isValidEmail(), isTrue,
              reason: 'Email ${user.email} should be valid');
        }
      });

      test('should invalidate incorrect email formats', () {
        final invalidEmails = [
          User(id: 1, name: 'Test', email: '', createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: 'invalid-email',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: 'test@',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: '@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: 'test@@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'Test',
              email: 'test .email@example.com',
              createdAt: DateTime(2025, 1, 1)),
        ];

        for (final user in invalidEmails) {
          expect(user.isValidEmail(), isFalse,
              reason: 'Email ${user.email} should be invalid');
        }
      });
    });

    group('Name Validation', () {
      test('should validate correct name formats', () {
        final validNames = [
          User(
              id: 1,
              name: 'Jo',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'John Doe',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'A very long name but still within fifty chars limit',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
        ];

        for (final user in validNames) {
          expect(user.isValidName(), isTrue,
              reason: 'Name "${user.name}" should be valid');
        }
      });

      test('should invalidate incorrect name formats', () {
        final invalidNames = [
          User(
              id: 1,
              name: '',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name: 'A',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
          User(
              id: 1,
              name:
                  'This name is way too long and exceeds the fifty character limit definitely',
              email: 'test@example.com',
              createdAt: DateTime(2025, 1, 1)),
        ];

        for (final user in invalidNames) {
          expect(user.isValidName(), isFalse,
              reason: 'Name "${user.name}" should be invalid');
        }
      });
    });

    group('Overall Validation', () {
      test('should validate user with all valid fields', () {
        final validUser = User(
          id: 1,
          name: 'John Doe',
          email: 'john@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(validUser.isValid(), isTrue);
      });

      test('should invalidate user with invalid email', () {
        final invalidUser = User(
          id: 1,
          name: 'John Doe',
          email: 'invalid-email',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(invalidUser.isValid(), isFalse);
      });

      test('should invalidate user with invalid name', () {
        final invalidUser = User(
          id: 1,
          name: '',
          email: 'john@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(invalidUser.isValid(), isFalse);
      });
    });

    group('ToString Method', () {
      test('should provide meaningful string representation', () {
        final userString = testUser.toString();

        expect(userString, contains('User'));
        expect(userString, contains('1'));
        expect(userString, contains('John Doe'));
        expect(userString, contains('john@example.com'));
      });

      test('should be consistent for same user', () {
        final user1 = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        final user2 = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          createdAt: DateTime(2025, 1, 1),
        );

        expect(user1.toString(), equals(user2.toString()));
      });
    });
  });
}
