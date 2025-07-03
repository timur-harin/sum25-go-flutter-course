class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(seconds: 1));
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}
