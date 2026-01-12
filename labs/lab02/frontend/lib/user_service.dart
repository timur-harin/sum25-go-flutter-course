class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}
    await Future.delayed(Duration(milliseconds: 300));
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}
