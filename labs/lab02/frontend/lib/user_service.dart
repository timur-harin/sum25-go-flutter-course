class UserService {
  Future<Map<String, String>> fetchUser() async {
    // Simulating fetching user data
    await Future.delayed(const Duration(milliseconds: 10));
    return {
      'name': 'Alice',
      'email': 'alice@example.com',
    };
  }
}