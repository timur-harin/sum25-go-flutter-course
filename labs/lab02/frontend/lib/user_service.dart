class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(const Duration(milliseconds: 5));
    return {'name': "A", 'email': "example@example.com"};
  }
}
