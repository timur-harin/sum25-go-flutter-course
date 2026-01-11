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
  final JWTServiceInterface _jwtService;
  final UserRepositoryInterface _userRepository;

  AuthState _currentState = const AuthState();

  AuthService({
    JWTServiceInterface? jwtService,
    UserRepositoryInterface? userRepository,
  })  : _jwtService = jwtService ?? _MockJWTService(),
        _userRepository = userRepository ?? _MockUserRepository();

  AuthState get currentState => _currentState;

  bool get isAuthenticated => _currentState.isAuthenticated;
  User? get currentUser => _currentState.currentUser;

  Future<AuthResult> login(String email, String password) async {
    try {
      final sanitizedEmail = FormValidator.sanitizeText(email);
      final sanitizedPassword = FormValidator.sanitizeText(password);

      if (FormValidator.validateEmail(sanitizedEmail) != null ||
          FormValidator.validatePassword(sanitizedPassword) != null) {
        return AuthResult.validationError;
      }

      final user = await _userRepository.findByEmail(sanitizedEmail);
      if (user == null) return AuthResult.invalidCredentials;

      final valid = await _userRepository.verifyPassword(sanitizedEmail, sanitizedPassword);
      if (!valid) return AuthResult.invalidCredentials;

      final token = _jwtService.generateToken(user.id.toString(), user.email);
      _currentState = _currentState.copyWith(
        isAuthenticated: true,
        currentUser: user,
        token: token,
        loginTime: DateTime.now(),
      );

      return AuthResult.success;
    } catch (_) {
      return AuthResult.networkError;
    }
  }

  Future<void> logout() async {
    _currentState = const AuthState();
  }

  bool isSessionValid() {
    if (!_currentState.isAuthenticated || _currentState.loginTime == null) return false;
    return DateTime.now().difference(_currentState.loginTime!).inHours < 24;
  }

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

  Map<String, dynamic>? getUserInfo() {
    if (!_currentState.isAuthenticated || _currentState.currentUser == null) return null;

    return {
      'id': _currentState.currentUser!.id,
      'name': _currentState.currentUser!.name,
      'email': _currentState.currentUser!.email,
      'loginTime': _currentState.loginTime?.toIso8601String(),
      'sessionValid': isSessionValid(),
    };
  }
}

// ---------------------- Mock Implementations ----------------------

class _MockJWTService implements JWTServiceInterface {
  @override
  String generateToken(String userId, String email) {
    return 'header.payload_${userId}_${email}_${DateTime.now().millisecondsSinceEpoch}.signature';
  }

  @override
  bool validateToken(String token) {
    if (!token.contains('header.payload_') || !token.contains('.signature')) return false;

    try {
      final parts = token.split('_');
      final timestampStr = parts[2].split('.')[0];
      final timestamp = int.parse(timestampStr);
      final tokenTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return DateTime.now().difference(tokenTime).inHours < 24;
    } catch (_) {
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
    } catch (_) {
      return null;
    }
  }
}

class _MockUserRepository implements UserRepositoryInterface {
  static final Map<String, Map<String, String>> _users = {
    'test@example.com': {
      'id': '1',
      'name': 'Test User',
      'password': 'password123',
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
    await Future.delayed(const Duration(milliseconds: 100));
    final data = _users[email];
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
    final data = _users[email];
    if (data == null) return false;
    return data['password'] == password;
  }
}