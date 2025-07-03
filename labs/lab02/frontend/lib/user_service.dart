class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(Duration(milliseconds: 1));
    return {
      'name': 'Alice',
      'email': 'alice@example.com',
    };
  }
}