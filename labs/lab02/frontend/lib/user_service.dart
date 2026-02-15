class UserService {
  Future<Map<String, String>> fetchUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 10));
    // Return mock user data
    return {'name': 'John Doe', 'email': 'john.doe@example.com'};
  }
}