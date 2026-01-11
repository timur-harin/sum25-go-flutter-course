import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_frontend/core/validation/form_validator.dart';
import 'package:lab05_frontend/domain/entities/user.dart';

// Authentication result enum
enum AuthResult {
  success,
  invalidCredentials,
  validationError,
  networkError,
  unknown
}

// Authentication state
class AuthState {
  final bool isAuthenticated;
  final User? currentUser;
  final String? token;
  final DateTime? loginTime;

  const AuthState({
    this.isAuthenticated = false,
    this.currentUser,
    this.token,
    this.loginTime,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    User? currentUser,
    String? token,
    DateTime? loginTime,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      currentUser: currentUser ?? this.currentUser,
      token: token ?? this.token,
      loginTime: loginTime ?? this.loginTime,
    );
  }
}

// Mock JWT service interface for dependency injection
abstract class JWTServiceInterface {
  String generateToken(String userId, String email);
  bool validateToken(String token);
  Map<String, dynamic>? extractClaims(String token);
}

// Mock user repository interface
abstract class UserRepositoryInterface {
  Future<User?> findByEmail(String email);
  Future<bool> verifyPassword(String email, String password);
}

// Authentication service implementing clean architecture
class AuthService {
  final FormValidator _validator;
  final JWTServiceInterface _jwtService;
  final UserRepositoryInterface _userRepository;

  AuthState _currentState = const AuthState();

  // Constructor with dependency injection
  AuthService({
    FormValidator? validator,
    JWTServiceInterface? jwtService,
    UserRepositoryInterface? userRepository,
  })  : _validator = validator ?? FormValidator(),
        _jwtService = jwtService ?? _MockJWTService(),
        _userRepository = userRepository ?? _MockUserRepository();

  // Get current authentication state
  AuthState get currentState => _currentState;

  // Check if user is currently authenticated
  bool get isAuthenticated => _currentState.isAuthenticated;

  // Get current user
  User? get currentUser => _currentState.currentUser;

  // login implementation
  Future<AuthResult> login(String email, String password) async {
    try {
      if (FormValidator.validateEmail(email) != null ||
          FormValidator.validatePassword(password) != null) {
        return AuthResult.validationError;
      }

      email = FormValidator.sanitizeText(email);

      User? user = await _userRepository.findByEmail(email);
      if (user == null) return AuthResult.invalidCredentials;

      bool? isValidPassword =
          await _userRepository.verifyPassword(email, password);
      if (!isValidPassword) return AuthResult.invalidCredentials;

      String token = _jwtService.generateToken(user.id.toString(), user.email);

      _currentState = _currentState.copyWith(
        isAuthenticated: true,
        currentUser: user,
        token: token,
        loginTime: DateTime.now(),
      );

      return AuthResult.success;
    } catch (e) {
      return AuthResult.networkError;
    }
  }

  // logout implementation
  Future<void> logout() async {
    _currentState = const AuthState();
  }

  // isSessionValid method implementation
  bool isSessionValid() {
    if (!_currentState.isAuthenticated) return false;
    if (_currentState.loginTime == null) return false;

    final duration = DateTime.now().difference(_currentState.loginTime!);
    return duration.inHours < 24;
  }

  // refreshAuto implementation
  Future<bool> refreshAuth() async {
    try {
      if (!isSessionValid()) {
        await logout();
        return false;
      }

      if (_currentState.token != null) {
        if (!_jwtService.validateToken(_currentState.token!)) {
          await logout();
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // getUserInfo method implementation
  Map<String, dynamic>? getUserInfo() {
    if (!isAuthenticated || currentUser == null) return null;

    return {
      'id': currentUser!.id,
      'name': currentUser!.name,
      'email': currentUser!.email,
      'loginTime': _currentState.loginTime?.toIso8601String(),
      'sessionValid': isSessionValid(),
    };
  }
}

// Mock implementations for testing (in real app, these would be separate files)
class _MockJWTService implements JWTServiceInterface {
  @override
  String generateToken(String userId, String email) {
    // Mock JWT token generation
    final payload =
        'header.payload_${userId}_${email}_${DateTime.now().millisecondsSinceEpoch}.signature';
    return payload;
  }

  @override
  bool validateToken(String token) {
    // Mock validation - check format and not too old
    if (!token.contains('header.payload_') || !token.contains('.signature')) {
      return false;
    }

    try {
      final parts = token.split('_');
      if (parts.length < 3) return false;

      final timestampStr = parts[2].split('.')[0];
      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final age = DateTime.now().difference(tokenTime);

      return age.inHours < 24;
    } catch (e) {
      return false;
    }
  }

  @override
  Map<String, dynamic>? extractClaims(String token) {
    if (!validateToken(token)) return null;

    try {
      final parts = token.split('_');
      return {
        'userId': parts[1],
        'email': parts[2],
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (24 * 60 * 60),
      };
    } catch (e) {
      return null;
    }
  }
}

class _MockUserRepository implements UserRepositoryInterface {
  // Mock user database
  static final Map<String, Map<String, String>> _users = {
    'test@example.com': {
      'id': '1',
      'name': 'Test User',
      'password': 'password123', // In real app, this would be hashed
    },
    'john@example.com': {
      'id': '2',
      'name': 'John Doe',
      'password': 'mypassword1',
    },
    'jane@example.com': {
      'id': '3',
      'name': 'Jane Smith',
      'password': 'securepass2',
    },
  };

  @override
  Future<User?> findByEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    final userData = _users[email];
    if (userData == null) return null;

    return User(
      id: int.parse(userData['id']!),
      name: userData['name']!,
      email: email,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<bool> verifyPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    final userData = _users[email];
    if (userData == null) return false;

    // In real app, would use bcrypt to compare hashed password
    return userData['password'] == password;
  }
}
