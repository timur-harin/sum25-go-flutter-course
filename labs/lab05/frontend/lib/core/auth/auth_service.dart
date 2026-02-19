import 'package:flutter_test/flutter_test.dart'; // kept for compatibility with tests
import 'package:lab05_frontend/core/validation/form_validator.dart';
import 'package:lab05_frontend/domain/entities/user.dart';

/// Possible outcomes of an authentication attempt.
enum AuthResult {
  success,
  invalidCredentials,
  validationError,
  networkError,
  unknown,
}

/// Simple value object that describes the current authentication context.
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

/// Contract for all JWT engines that may be injected.
abstract class JWTServiceInterface {
  String generateToken(String userId, String email);
  bool validateToken(String token);
  Map<String, dynamic>? extractClaims(String token);
}

/// Repository contract that hides the underlying data-source.
abstract class UserRepositoryInterface {
  Future<User?> findByEmail(String email);
  Future<bool> verifyPassword(String email, String password);
}

/// High-level authentication façade.
///
/// * All dependencies are injected (clean architecture).
/// * Only pure Dart code, therefore fully unit-testable.
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

  /// Tries to sign in with *email* / *password*.
  Future<AuthResult> login(String email, String password) async {
    // 1. Input validation ----------------------------------------------------
    final emailError = FormValidator.validateEmail(email);
    final passwordError = FormValidator.validatePassword(password);
    if (emailError != null || passwordError != null) {
      return AuthResult.validationError;
    }

    // 2. Sanitize e-mail and query repository -------------------------------
    final sanitizedEmail = FormValidator.sanitizeText(email);

    try {
      final user = await _userRepository.findByEmail(sanitizedEmail);
      if (user == null) {
        return AuthResult.invalidCredentials;
      }

      final passwordCorrect =
          await _userRepository.verifyPassword(sanitizedEmail, password);
      if (!passwordCorrect) {
        return AuthResult.invalidCredentials;
      }

      // 3. Everything is fine – create a new authenticated state -------------
      final token = _jwtService.generateToken(user.id.toString(), user.email);
      _currentState = AuthState(
        isAuthenticated: true,
        currentUser: user,
        token: token,
        loginTime: DateTime.now(),
      );
      return AuthResult.success;
    } catch (_) {
      // Any I/O problem is considered a network issue for lab purposes.
      return AuthResult.networkError;
    }
  }

  /// Clears the current session data.
  Future<void> logout() async {
    _currentState = const AuthState();
  }

  /// Returns `true` when the active session is < 24 h old.
  bool isSessionValid() {
    if (!_currentState.isAuthenticated) return false;
    final loginTime = _currentState.loginTime;
    if (loginTime == null) return false;
    return DateTime.now().difference(loginTime).inHours < 24;
  }

  /// Re-validates both the session age **and** the JWT itself.
  ///
  /// Returns `true` when everything is still valid, otherwise logs out and
  /// returns `false`.
  Future<bool> refreshAuth() async {
    try {
      if (!isSessionValid()) {
        await logout();
        return false;
      }

      final token = _currentState.token;
      if (token == null || !_jwtService.validateToken(token)) {
        await logout();
        return false;
      }

      return true;
    } catch (_) {
      await logout();
      return false;
    }
  }

  /// Convenience helper that exposes limited user info to UI.
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

/* -------------------------------------------------------------------------- */
/* Default mock implementations – used by tests when no custom DI is provided */
/* -------------------------------------------------------------------------- */

class _MockJWTService implements JWTServiceInterface {
  @override
  String generateToken(String userId, String email) =>
      'header.payload_${userId}_${email}_${DateTime.now().millisecondsSinceEpoch}.signature';

  @override
  bool validateToken(String token) {
    if (!token.contains('header.payload_') || !token.contains('.signature')) {
      return false;
    }
    try {
      final parts = token.split('_');
      if (parts.length < 3) return false;
      final ts = int.parse(parts[2].split('.')[0]);
      final age =
          DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
      return age.inHours < 24;
    } catch (_) {
      return false;
    }
  }

  @override
  Map<String, dynamic>? extractClaims(String token) {
    if (!validateToken(token)) return null;
    final parts = token.split('_');
    return {
      'userId': parts[1],
      'email': parts[2],
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 86400,
    };
  }
}

class _MockUserRepository implements UserRepositoryInterface {
  static final Map<String, Map<String, String>> _db = {
    'test@example.com': {
      'id': '1',
      'name': 'Test User',
      // NOTE: plain-text for lab simplicity – never in production.
      'password': 'password123',
    },
  };

  @override
  Future<User?> findByEmail(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final data = _db[email];
    if (data == null) return null;
    return User(
      id: int.parse(data['id']!),
      name: data['name']!,
      email: email,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<bool> verifyPassword(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final data = _db[email];
    if (data == null) return false;
    return data['password'] == password;
  }
}
