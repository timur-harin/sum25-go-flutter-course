class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {'name': 'Test User', 'email': 'test@example.com'};
  }
}
