class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'name': 'Test User',
      'email': 'test.user@example.com',
    };
  }
}