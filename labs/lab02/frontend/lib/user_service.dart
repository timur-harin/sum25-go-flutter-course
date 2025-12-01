class UserService {
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    if (fail) {
      throw Exception('Failed');
    }
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 10));
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}
