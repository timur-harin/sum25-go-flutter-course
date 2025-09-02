class UserService {
  bool shouldFail = false;

  Future<Map<String, String>> fetchUser() async {
    // Simulate fetching user data for tests
    await Future.delayed(const Duration(milliseconds: 300));
    if (shouldFail) {
      throw Exception('error: failed to fetch user');
    }
    return {
      'name': 'Alice',
      'email': 'alice@example.com',
      'id': 'alice123',
    };
  }

  Future<Map<String, String>> getUser() => fetchUser();
}
