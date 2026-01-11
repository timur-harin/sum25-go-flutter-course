class UserService {
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (fail) {
      throw Exception('Error: Failed to fetch user');
    }
    return {
      'name': 'Alice',
      'email': 'alice@example.com',
    };
  }
}
