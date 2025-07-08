import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:lab04_frontend/services/database_service.dart';
import 'package:lab04_frontend/models/user.dart';

void main() {
  group('DatabaseService Tests', () {
    setUpAll(() {
      // Initialize ffi for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Clean up database before each test
      try {
        await DatabaseService.clearAllData();
      } catch (e) {
        // Database might not exist yet, which is fine
      }
    });

    tearDown(() async {
      // Clean up after each test
      try {
        await DatabaseService.closeDatabase();
      } catch (e) {
        // Ignore cleanup errors
      }
    });

    test('should initialize database', () async {
      final db = await DatabaseService.database;
      expect(db, isNotNull);
    });

    test('should create user successfully', () async {
      final request = CreateUserRequest(
        name: 'John Doe',
        email: 'john@example.com',
      );

      final user = await DatabaseService.createUser(request);

      expect(user.id, greaterThan(0));
      expect(user.name, equals(request.name));
      expect(user.email, equals(request.email));
      expect(user.createdAt, isNotNull);
      expect(user.updatedAt, isNotNull);
    });

    test('should get user by ID', () async {
      final request = CreateUserRequest(
        name: 'Jane Doe',
        email: 'jane@example.com',
      );

      final createdUser = await DatabaseService.createUser(request);
      final retrievedUser = await DatabaseService.getUser(createdUser.id);

      expect(retrievedUser, isNotNull);
      expect(retrievedUser!.id, equals(createdUser.id));
      expect(retrievedUser.name, equals(createdUser.name));
      expect(retrievedUser.email, equals(createdUser.email));
    });

    test('should return null for non-existent user ID', () async {
      final user = await DatabaseService.getUser(99999);
      expect(user, isNull);
    });

    test('should get all users', () async {
      final requests = [
        CreateUserRequest(name: 'User 1', email: 'user1@example.com'),
        CreateUserRequest(name: 'User 2', email: 'user2@example.com'),
        CreateUserRequest(name: 'User 3', email: 'user3@example.com'),
      ];

      for (final request in requests) {
        await DatabaseService.createUser(request);
      }

      final users = await DatabaseService.getAllUsers();
      expect(users.length, equals(requests.length));

      for (int i = 0; i < requests.length; i++) {
        expect(users.any((u) => u.name == requests[i].name), isTrue);
        expect(users.any((u) => u.email == requests[i].email), isTrue);
      }
    });

    test('should return empty list when no users exist', () async {
      final users = await DatabaseService.getAllUsers();
      expect(users, isEmpty);
    });

    test('should update user successfully', () async {
      final request = CreateUserRequest(
        name: 'Original Name',
        email: 'original@example.com',
      );

      final createdUser = await DatabaseService.createUser(request);

      final updates = {
        'name': 'Updated Name',
        'email': 'updated@example.com',
      };

      final updatedUser =
          await DatabaseService.updateUser(createdUser.id, updates);

      expect(updatedUser.id, equals(createdUser.id));
      expect(updatedUser.name, equals('Updated Name'));
      expect(updatedUser.email, equals('updated@example.com'));
      expect(updatedUser.updatedAt.isAfter(createdUser.updatedAt), isTrue);
    });

    test('should update only specified fields', () async {
      final request = CreateUserRequest(
        name: 'Original Name',
        email: 'original@example.com',
      );

      final createdUser = await DatabaseService.createUser(request);

      final updates = {
        'name': 'Updated Name Only',
      };

      final updatedUser =
          await DatabaseService.updateUser(createdUser.id, updates);

      expect(updatedUser.name, equals('Updated Name Only'));
      expect(updatedUser.email,
          equals(createdUser.email)); // Should remain unchanged
    });

    test('should delete user successfully', () async {
      final request = CreateUserRequest(
        name: 'To Be Deleted',
        email: 'delete@example.com',
      );

      final createdUser = await DatabaseService.createUser(request);

      await DatabaseService.deleteUser(createdUser.id);

      final deletedUser = await DatabaseService.getUser(createdUser.id);
      expect(deletedUser, isNull);
    });

    test('should count users correctly', () async {
      final initialCount = await DatabaseService.getUserCount();
      expect(initialCount, equals(0));

      final requests = [
        CreateUserRequest(name: 'Counter 1', email: 'counter1@example.com'),
        CreateUserRequest(name: 'Counter 2', email: 'counter2@example.com'),
      ];

      for (final request in requests) {
        await DatabaseService.createUser(request);
      }

      final finalCount = await DatabaseService.getUserCount();
      expect(finalCount, equals(requests.length));
    });

    test('should search users by name', () async {
      final requests = [
        CreateUserRequest(name: 'John Smith', email: 'john@example.com'),
        CreateUserRequest(name: 'Jane Doe', email: 'jane@example.com'),
        CreateUserRequest(name: 'Bob Johnson', email: 'bob@example.com'),
      ];

      for (final request in requests) {
        await DatabaseService.createUser(request);
      }

      final searchResults = await DatabaseService.searchUsers('John');
      expect(searchResults.length, equals(2)); // John Smith and Bob Johnson
      expect(searchResults.any((u) => u.name.contains('John')), isTrue);
    });

    test('should search users by email', () async {
      final requests = [
        CreateUserRequest(name: 'Test User 1', email: 'test1@gmail.com'),
        CreateUserRequest(name: 'Test User 2', email: 'test2@yahoo.com'),
        CreateUserRequest(name: 'Test User 3', email: 'test3@gmail.com'),
      ];

      for (final request in requests) {
        await DatabaseService.createUser(request);
      }

      final searchResults = await DatabaseService.searchUsers('gmail');
      expect(searchResults.length, equals(2)); // Users with gmail addresses
      expect(searchResults.every((u) => u.email.contains('gmail')), isTrue);
    });

    test('should return empty search results for non-matching query', () async {
      final request = CreateUserRequest(
        name: 'Test User',
        email: 'test@example.com',
      );

      await DatabaseService.createUser(request);

      final searchResults = await DatabaseService.searchUsers('nonexistent');
      expect(searchResults, isEmpty);
    });

    test('should get database path', () async {
      final path = await DatabaseService.getDatabasePath();
      expect(path, isNotEmpty);
      expect(path.contains('lab04_app.db'), isTrue);
    });

    test('should clear all data', () async {
      final request = CreateUserRequest(
        name: 'Test User',
        email: 'test@example.com',
      );

      await DatabaseService.createUser(request);

      var count = await DatabaseService.getUserCount();
      expect(count, equals(1));

      await DatabaseService.clearAllData();

      count = await DatabaseService.getUserCount();
      expect(count, equals(0));
    });
  });
}
