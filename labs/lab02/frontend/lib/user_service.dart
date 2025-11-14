import 'dart:async';

class UserService {
  bool _shouldFail = false;
  Duration _simulatedDelay = Duration.zero;

  /// Set this to true to simulate failed requests
  set shouldFail(bool value) => _shouldFail = value;

  /// Set the simulated network delay duration
  set simulatedDelay(Duration delay) => _simulatedDelay = delay;

  /// Fetches user data from the service
  ///
  /// Returns a map containing user information with keys:
  /// - 'name': String - user's name
  /// - 'email': String - user's email address
  ///
  /// Throws [Exception] if the request fails
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(_simulatedDelay);

    if (_shouldFail) {
      throw Exception('Failed');
    }

    return {
      'name': 'Alice',
      'email': 'alice@example.com',
    };
  }

  /// Simulates updating user data (for testing purposes)
  Future<void> updateUser(Map<String, String> newData) async {
    await Future.delayed(_simulatedDelay);

    if (_shouldFail) {
      throw Exception('Update failed');
    }
  }
}
