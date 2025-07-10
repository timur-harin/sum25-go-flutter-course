import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_frontend/core/auth/auth_service.dart';
import 'package:lab05_frontend/core/validation/form_validator.dart';
import 'package:lab05_frontend/domain/entities/user.dart';

// Mock implementations for testing
class TestJWTService implements JWTServiceInterface {
  bool _shouldFailValidation = false;
  bool _shouldReturnInvalidClaims = false;

  void setShouldFailValidation(bool fail) {
    _shouldFailValidation = fail;
  }

  void setShouldReturnInvalidClaims(bool invalid) {
    _shouldReturnInvalidClaims = invalid;
  }

  @override
  String generateToken(String userId, String email) {
    return 'test.jwt.token_${userId}_${email}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  bool validateToken(String token) {
    if (_shouldFailValidation) return false;
    return token.startsWith('test.jwt.token_');
  }

  @override
  Map<String, dynamic>? extractClaims(String token) {
    if (_shouldReturnInvalidClaims) return null;
    if (!validateToken(token)) return null;

    return {
      'userId': '1',
      'email': 'test@example.com',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (24 * 60 * 60),
    };
  }
}

class TestUserRepository implements UserRepositoryInterface {
  bool _shouldReturnNullUser = false;
  bool _shouldFailPasswordVerification = false;
  bool _shouldThrowException = false;

  void setShouldReturnNullUser(bool returnNull) {
    _shouldReturnNullUser = returnNull;
  }

  void setShouldFailPasswordVerification(bool fail) {
    _shouldFailPasswordVerification = fail;
  }

  void setShouldThrowException(bool throwError) {
    _shouldThrowException = throwError;
  }

  @override
  Future<User?> findByEmail(String email) async {
    if (_shouldThrowException) {
      throw Exception('Network error');
    }

    if (_shouldReturnNullUser) {
      return null;
    }

    return User(
      id: 1,
      name: 'Test User',
      email: email,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<bool> verifyPassword(String email, String password) async {
    if (_shouldThrowException) {
      throw Exception('Network error');
    }

    return !_shouldFailPasswordVerification;
  }
}

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late TestJWTService testJWTService;
    late TestUserRepository testUserRepository;

    setUp(() {
      testJWTService = TestJWTService();
      testUserRepository = TestUserRepository();
      authService = AuthService(
        jwtService: testJWTService,
        userRepository: testUserRepository,
      );
    });

    group('Authentication State Management', () {
      test('should start with unauthenticated state', () {
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentState.isAuthenticated, isFalse);
        expect(authService.currentState.currentUser, isNull);
        expect(authService.currentState.token, isNull);
        expect(authService.currentState.loginTime, isNull);
      });

      test('should update state after successful login', () async {
        const email = 'test@example.com';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.success));
        expect(authService.isAuthenticated, isTrue);
        expect(authService.currentUser, isNotNull);
        expect(authService.currentUser?.email, equals(email));
        expect(authService.currentState.token, isNotNull);
        expect(authService.currentState.loginTime, isNotNull);
      });

      test('should clear state after logout', () async {
        // First login
        await authService.login('test@example.com', 'password123');
        expect(authService.isAuthenticated, isTrue);

        // Then logout
        await authService.logout();
        expect(authService.isAuthenticated, isFalse);
        expect(authService.currentUser, isNull);
        expect(authService.currentState.token, isNull);
        expect(authService.currentState.loginTime, isNull);
      });
    });

    group('Login Functionality', () {
      test('should return success for valid credentials', () async {
        const email = 'test@example.com';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.success));
        expect(authService.currentUser?.email, equals(email));
      });

      test('should return validation error for invalid email', () async {
        const email = 'invalid-email';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.validationError));
        expect(authService.isAuthenticated, isFalse);
      });

      test('should return validation error for invalid password', () async {
        const email = 'test@example.com';
        const password = '123'; // Too short

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.validationError));
        expect(authService.isAuthenticated, isFalse);
      });

      test('should return validation error for empty email', () async {
        const email = '';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.validationError));
      });

      test('should return validation error for empty password', () async {
        const email = 'test@example.com';
        const password = '';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.validationError));
      });

      test('should return invalid credentials when user not found', () async {
        testUserRepository.setShouldReturnNullUser(true);

        const email = 'test@example.com';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.invalidCredentials));
        expect(authService.isAuthenticated, isFalse);
      });

      test('should return invalid credentials for wrong password', () async {
        testUserRepository.setShouldFailPasswordVerification(true);

        const email = 'test@example.com';
        const password = 'password123'; // Valid format but wrong credentials

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.invalidCredentials));
        expect(authService.isAuthenticated, isFalse);
      });

      test('should return network error when repository throws exception',
          () async {
        testUserRepository.setShouldThrowException(true);

        const email = 'test@example.com';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.networkError));
        expect(authService.isAuthenticated, isFalse);
      });

      test('should sanitize email input', () async {
        const email = '  test@example.com  '; // Test whitespace trimming
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.success));
        // Email should be sanitized by FormValidator.sanitizeText (trimmed)
        expect(authService.currentUser?.email, equals('test@example.com'));
      });
    });

    group('Session Management', () {
      test('should validate session as valid immediately after login',
          () async {
        await authService.login('test@example.com', 'password123');

        expect(authService.isSessionValid(), isTrue);
      });

      test('should return false for session validity when not authenticated',
          () {
        expect(authService.isSessionValid(), isFalse);
      });

      test('should refresh auth successfully for valid session', () async {
        await authService.login('test@example.com', 'password123');

        final refreshResult = await authService.refreshAuth();

        expect(refreshResult, isTrue);
        expect(authService.isAuthenticated, isTrue);
      });

      test('should logout during refresh when token validation fails',
          () async {
        await authService.login('test@example.com', 'password123');

        // Make JWT service fail validation to simulate invalid token
        testJWTService.setShouldFailValidation(true);

        final refreshResult = await authService.refreshAuth();

        expect(refreshResult, isFalse);
        expect(authService.isAuthenticated, isFalse);
      });

      test('should logout during refresh when token is invalid', () async {
        await authService.login('test@example.com', 'password123');
        testJWTService.setShouldFailValidation(true);

        final refreshResult = await authService.refreshAuth();

        expect(refreshResult, isFalse);
        expect(authService.isAuthenticated, isFalse);
      });
    });

    group('User Info Retrieval', () {
      test('should return user info when authenticated', () async {
        await authService.login('test@example.com', 'password123');

        final userInfo = authService.getUserInfo();

        expect(userInfo, isNotNull);
        expect(userInfo!['id'], equals(1));
        expect(userInfo['name'], equals('Test User'));
        expect(userInfo['email'], equals('test@example.com'));
        expect(userInfo['loginTime'], isNotNull);
        expect(userInfo['sessionValid'], isTrue);
      });

      test('should return null when not authenticated', () {
        final userInfo = authService.getUserInfo();

        expect(userInfo, isNull);
      });

      test('should return null after logout', () async {
        await authService.login('test@example.com', 'password123');
        await authService.logout();

        final userInfo = authService.getUserInfo();

        expect(userInfo, isNull);
      });
    });

    group('Constructor and Dependency Injection', () {
      test('should work with default dependencies', () {
        final service = AuthService();

        expect(service, isA<AuthService>());
        expect(service.isAuthenticated, isFalse);
      });

      test('should work with custom dependencies', () {
        final customJWT = TestJWTService();
        final customRepo = TestUserRepository();

        final service = AuthService(
          jwtService: customJWT,
          userRepository: customRepo,
        );

        expect(service, isA<AuthService>());
        expect(service.isAuthenticated, isFalse);
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle whitespace in credentials', () async {
        const email = '  test@example.com  ';
        const password = 'password123';

        final result = await authService.login(email, password);

        expect(result, equals(AuthResult.success));
        expect(authService.currentUser?.email, equals('test@example.com'));
      });

      test('should handle multiple consecutive login attempts', () async {
        // First login
        final result1 =
            await authService.login('test@example.com', 'password123');
        expect(result1, equals(AuthResult.success));

        // Second login (should replace first session)
        final result2 =
            await authService.login('test@example.com', 'password123');
        expect(result2, equals(AuthResult.success));
        expect(authService.isAuthenticated, isTrue);
      });

      test('should handle login after logout', () async {
        // Login, logout, then login again
        await authService.login('test@example.com', 'password123');
        await authService.logout();

        final result =
            await authService.login('test@example.com', 'password123');
        expect(result, equals(AuthResult.success));
        expect(authService.isAuthenticated, isTrue);
      });

      test('should handle refresh when not authenticated', () async {
        final refreshResult = await authService.refreshAuth();

        expect(refreshResult, isFalse);
        expect(authService.isAuthenticated, isFalse);
      });
    });

    group('Authentication Results', () {
      test('should cover all authentication result types', () {
        expect(AuthResult.values.length, equals(5));
        expect(AuthResult.values, contains(AuthResult.success));
        expect(AuthResult.values, contains(AuthResult.invalidCredentials));
        expect(AuthResult.values, contains(AuthResult.validationError));
        expect(AuthResult.values, contains(AuthResult.networkError));
        expect(AuthResult.values, contains(AuthResult.unknown));
      });
    });

    group('AuthState functionality', () {
      test('should create auth state with copyWith', () {
        const originalState = AuthState();
        final user = User(
          id: 1,
          name: 'Test',
          email: 'test@example.com',
          createdAt: DateTime.now(),
        );

        final newState = originalState.copyWith(
          isAuthenticated: true,
          currentUser: user,
          token: 'test-token',
          loginTime: DateTime.now(),
        );

        expect(newState.isAuthenticated, isTrue);
        expect(newState.currentUser, equals(user));
        expect(newState.token, equals('test-token'));
        expect(newState.loginTime, isNotNull);
      });
    });
  });
}
