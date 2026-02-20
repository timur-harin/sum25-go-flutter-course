class UserService {
  bool fail = false;
  Future<Map<String, String>> fetchUser() async {
    if (fail) throw Exception("failed");
    await Future.delayed(Duration(microseconds: 10));
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}
