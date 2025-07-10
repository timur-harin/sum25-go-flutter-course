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

  // TODO: Implement login method
  // login authenticates a user with email and password
  // Requirements:
  // - Validate email and password using FormValidator.validateEmail() and FormValidator.validatePassword()
  // - Return AuthResult.validationError if either validation fails
  // - Sanitize email input using FormValidator.sanitizeText()
  // - Use _userRepository.findByEmail() to get user
  // - Return AuthResult.invalidCredentials if user not found
  // - Use _userRepository.verifyPassword() to check password
  // - Return AuthResult.invalidCredentials if password verification fails
  // - Generate JWT token using _jwtService.generateToken() with user.id.toString() and user.email
  // - Update _currentState with authenticated user, token, and current DateTime for loginTime
  // - Return AuthResult.success on successful authentication
  // - Return AuthResult.networkError if any exception occurs during the process
  Future<AuthResult> login(String email, String password) async {
    // TODO: Implement this method
    throw UnimplementedError('AuthService login not implemented');
  }

  // TODO: Implement logout method
  // logout clears the current authentication state
  // Requirements:
  // - Reset _currentState to a new empty AuthState()
  // - This should clear isAuthenticated, currentUser, token, and loginTime
  // - Method should complete without throwing exceptions
  Future<void> logout() async {
    // TODO: Implement this method
    throw UnimplementedError('AuthService logout not implemented');
  }

  // TODO: Implement isSessionValid method
  // isSessionValid checks if the current session is still valid
  // Requirements:
  // - Return false if not authenticated (!_currentState.isAuthenticated)
  // - Return false if loginTime is null
  // - Calculate time difference between current DateTime.now() and _currentState.loginTime
  // - Return true if session duration is less than 24 hours
  // - Return false if session has expired (24+ hours)
  bool isSessionValid() {
    // TODO: Implement this method
    throw UnimplementedError('AuthService isSessionValid not implemented');
  }

  // TODO: Implement refreshAuth method
  // refreshAuth validates and refreshes the current authentication status
  // Requirements:
  // - Call isSessionValid() to check session validity
  // - If session is invalid, call logout() and return false
  // - If token is present in _currentState.token, validate it using _jwtService.validateToken()
  // - If token validation fails, call logout() and return false
  // - Return true if session and token are valid
  // - Handle any exceptions and return false if errors occur
  Future<bool> refreshAuth() async {
    // TODO: Implement this method
    throw UnimplementedError('AuthService refreshAuth not implemented');
  }

  // TODO: Implement getUserInfo method
  // getUserInfo returns user information if authenticated
  // Requirements:
  // - Return null if not authenticated or currentUser is null
  // - Return a Map<String, dynamic> containing:
  //   - 'id': currentUser!.id
  //   - 'name': currentUser!.name
  //   - 'email': currentUser!.email
  //   - 'loginTime': _currentState.loginTime?.toIso8601String() (convert to string or null)
  //   - 'sessionValid': result of calling isSessionValid()
  Map<String, dynamic>? getUserInfo() {
    // TODO: Implement this method
    throw UnimplementedError('AuthService getUserInfo not implemented');
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
