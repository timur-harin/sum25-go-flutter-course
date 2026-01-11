import 'package:flutter_test/flutter_test.dart';
import 'package:lab05_frontend/core/validation/form_validator.dart';
import 'package:lab05_frontend/domain/entities/user.dart';

enum AuthResult {
  success,
  invalidCredentials,
  validationError,
  networkError,
  unknown
}

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

abstract class JWTServiceInterface {
  String generateToken(String userId, String email);
  bool validateToken(String token);
  Map<String, dynamic>? extractClaims(String token);
}

abstract class UserRepositoryInterface {
  Future<User?> findByEmail(String email);
  Future<bool> verifyPassword(String email, String password);
}

class AuthService {
  final FormValidator _validator;
  final JWTServiceInterface _jwtService;
  final UserRepositoryInterface _userRepository;

  AuthState _currentState = const AuthState();

  AuthService({
    FormValidator? validator,
    JWTServiceInterface? jwtService,
    UserRepositoryInterface? userRepository,
  })  : _validator = validator ?? FormValidator(),
        _jwtService = jwtService ?? _MockJWTService(),
        _userRepository = userRepository ?? _MockUserRepository();

  AuthState get currentState => _currentState;
  bool get isAuthenticated => _currentState.isAuthenticated;
  User? get currentUser => _currentState.currentUser;

  Future<AuthResult> login(String email, String password) async {
    try {
      final emailError = FormValidator.validateEmail(email);
      final passwordError = FormValidator.validatePassword(password);
      
      if (emailError != null || passwordError != null) {
        return AuthResult.validationError;
      }

      final sanitizedEmail = FormValidator.sanitizeText(email);
      final user = await _userRepository.findByEmail(sanitizedEmail);
      
      if (user == null) {
        return AuthResult.invalidCredentials;
      }

      final isPasswordValid = await _userRepository.verifyPassword(
        sanitizedEmail, 
        password
      );
      
      if (!isPasswordValid) {
        return AuthResult.invalidCredentials;
      }

      final token = _jwtService.generateToken(
        user.id.toString(),
        user.email
      );

      _currentState = AuthState(
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

  Future<void> logout() async {
    _currentState = const AuthState();
  }

  bool isSessionValid() {
    if (!_currentState.isAuthenticated || _currentState.loginTime == null) {
      return false;
    }
    return DateTime.now().difference(_currentState.loginTime!).inHours < 24;
  }

  Future<bool> refreshAuth() async {
    try {
      if (!isSessionValid()) {
        await logout();
        return false;
      }

      if (_currentState.token == null || 
          !_jwtService.validateToken(_currentState.token!)) {
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic>? getUserInfo() {
    if (!_currentState.isAuthenticated || _currentState.currentUser == null) {
      return null;
    }

    return {
      'id': _currentState.currentUser!.id,
      'name': _currentState.currentUser!.name,
      'email': _currentState.currentUser!.email,
      'loginTime': _currentState.loginTime?.toIso8601String(),
      'sessionValid': isSessionValid(),
    };
  }
}

class _MockJWTService implements JWTServiceInterface {
  @override
  String generateToken(String userId, String email) {
    return 'test.jwt.token_${userId}_${email}_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  bool validateToken(String token) {
    return token.startsWith('test.jwt.token_');
  }

  @override
  Map<String, dynamic>? extractClaims(String token) {
    if (!validateToken(token)) return null;
    return {
      'userId': '1',
      'email': 'test@example.com',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (24 * 60 * 60),
    };
  }
}

class _MockUserRepository implements UserRepositoryInterface {
  @override
  Future<User?> findByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return User(
      id: 1,
      name: 'Test User',
      email: email,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<bool> verifyPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return true;
  }
}