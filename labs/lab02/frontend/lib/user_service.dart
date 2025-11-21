class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(Duration(milliseconds: 200));
    return {'name': 'Test User', 'email': 'test@example.com'};
  }
}
