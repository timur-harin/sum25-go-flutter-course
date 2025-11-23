class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}
    await Future.delayed(const Duration(milliseconds: 10));
    return {'name': 'John Doe', 'email': 'john@example.com'};
  }
}
