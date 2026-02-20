class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}
    await Future.delayed(const Duration(seconds: 1));
    return {
      'name': 'Alice Smith',
      'email': 'alice.smith@example.com',
    };
  }
}