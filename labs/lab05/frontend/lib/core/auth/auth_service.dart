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
    try {
      // Perform validation checks for both email and password
      if (FormValidator.validateEmail(email) != null || FormValidator.validatePassword(password) != null) {
        return AuthResult.validationError;
      }
      
      // Clean the email input to prevent injection attacks
      String cleanedEmail = FormValidator.sanitizeText(email);
      
      // Attempt to locate user by email address
      User? foundUser = await _userRepository.findByEmail(cleanedEmail);
      if (foundUser == null) {
        return AuthResult.invalidCredentials;
      }
      
      // Verify the provided password matches stored credentials
      bool isPasswordValid = await _userRepository.verifyPassword(cleanedEmail, password);
      if (!isPasswordValid) {
        return AuthResult.invalidCredentials;
      }
      
      // Create authentication token for the validated user
      String authToken = _jwtService.generateToken(foundUser.id.toString(), foundUser.email);
      
      // Update authentication state with user info and token
      _currentState = _currentState.copyWith(
        isAuthenticated: true,
        currentUser: foundUser,
        token: authToken,
        loginTime: DateTime.now(),
      );
      
      return AuthResult.success;
    } catch (error) {
      return AuthResult.networkError;
    }
  }

  // logout clears the current authentication state
  // Requirements:
  // - Reset _currentState to a new empty AuthState()
  // - This should clear isAuthenticated, currentUser, token, and loginTime
  // - Method should complete without throwing exceptions
  Future<void> logout() async {
    _currentState = const AuthState();
  }

  // isSessionValid checks if the current session is still valid
  // Requirements:
  // - Return false if not authenticated (!_currentState.isAuthenticated)
  // - Return false if loginTime is null
  // - Calculate time difference between current DateTime.now() and _currentState.loginTime
  // - Return true if session duration is less than 24 hours
  // - Return false if session has expired (24+ hours)
  bool isSessionValid() {
    // Check if user is currently logged in
    if (!_currentState.isAuthenticated) {
      return false;
    }
    
    // Verify login timestamp exists
    DateTime? sessionStart = _currentState.loginTime;
    if (sessionStart == null) {
      return false;
    }
    
    // Calculate elapsed time since login
    Duration sessionDuration = DateTime.now().difference(sessionStart);
    
    // Session is valid if less than 24 hours have passed
    return sessionDuration.inHours < 24;
  }

  // refreshAuth validates and refreshes the current authentication status
  // Requirements:
  // - Call isSessionValid() to check session validity
  // - If session is invalid, call logout() and return false
  // - If token is present in _currentState.token, validate it using _jwtService.validateToken()
  // - If token validation fails, call logout() and return false
  // - Return true if session and token are valid
  // - Handle any exceptions and return false if errors occur
  Future<bool> refreshAuth() async {
    try {
      // First check if session hasn't expired
      if (!isSessionValid()) {
        await logout();
        return false;
      }
      
      // Retrieve current authentication token
      String? currentToken = _currentState.token;
      
      // Validate token exists and is still valid
      if (currentToken == null || !_jwtService.validateToken(currentToken)) {
        await logout();
        return false;
      }
      
      // Both session and token are valid
      return true;
    } catch (exception) {
      // Clear state on any error and return failure
      await logout();
      return false;
    }
  }

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
    // Return null if not authenticated or no user data
    if (!_currentState.isAuthenticated || _currentState.currentUser == null) {
      return null;
    }
    
    // Build user information map
    User activeUser = _currentState.currentUser!;
    return {
      'id': activeUser.id,
      'name': activeUser.name,
      'email': activeUser.email,
      'loginTime': _currentState.loginTime?.toIso8601String(),
      'sessionValid': isSessionValid(),
    };
  }
}

// Mock implementations for testing (in real app, these would be separate files)
class _MockJWTService implements JWTServiceInterface {
  @override
  String generateToken(String userId, String email) {
    // Create mock JWT token with timestamp
    int currentTimestamp = DateTime.now().millisecondsSinceEpoch;
    String tokenPayload = 'header.payload_${userId}_${email}_$currentTimestamp.signature';
    return tokenPayload;
  }

  @override
  bool validateToken(String token) {
    // Check basic token structure
    if (!token.startsWith('header.payload_') || !token.endsWith('.signature')) {
      return false;
    }

    try {
      // Extract timestamp from token
      List<String> tokenParts = token.split('_');
      if (tokenParts.length < 3) return false;

      String timestampPart = tokenParts[2].split('.')[0];
      int tokenTimestamp = int.parse(timestampPart);
      DateTime tokenCreated = DateTime.fromMillisecondsSinceEpoch(tokenTimestamp);
      
      // Check if token is within valid time range
      Duration tokenAge = DateTime.now().difference(tokenCreated);
      return tokenAge.inHours < 24;
    } catch (parseError) {
      return false;
    }
  }

  @override
  Map<String, dynamic>? extractClaims(String token) {
    // Only extract claims from valid tokens
    if (!validateToken(token)) return null;

    try {
      // Parse token components
      List<String> tokenComponents = token.split('_');
      int currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      
      return {
        'userId': tokenComponents[1],
        'email': tokenComponents[2],
        'iat': currentTime,
        'exp': currentTime + (24 * 60 * 60), // 24 hours from now
      };
    } catch (extractError) {
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
    // Simulate database lookup delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Check if user exists in mock database
    Map<String, String>? userRecord = _users[email];
    if (userRecord == null) return null;

    // Create User object from stored data
    return User(
      id: int.parse(userRecord['id']!),
      name: userRecord['name']!,
      email: email,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
  }

  @override
  Future<bool> verifyPassword(String email, String password) async {
    // Simulate password verification delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Look up user record
    Map<String, String>? userRecord = _users[email];
    if (userRecord == null) return false;

    // Compare passwords (in real app, would use secure hashing)
    return userRecord['password'] == password;
  }
}