class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(Duration(milliseconds: 10));
    return {
      'name': 'Test User',
      'email': 'testuser@example.com',
    };
  }
}
