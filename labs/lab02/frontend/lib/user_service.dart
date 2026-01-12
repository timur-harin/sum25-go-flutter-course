// lib/user_service.dart

/// UserService simulates fetching user data.
class UserService {
  /// Simulate fetching user data with a delay.
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Default user data
    return {
      'name': 'Sabina Yamilova',
      'email': 'sabina.yamilova@example.com',
    };
  }
}
