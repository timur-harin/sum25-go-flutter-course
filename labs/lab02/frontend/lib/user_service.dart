class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(microseconds: 10));
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}
