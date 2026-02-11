class UserService {
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}
    if (fail) throw Exception("User info fetch failed");
    await Future.delayed(Duration(milliseconds: 10));
    return {'name' : "Pavel", 'email' : "example@example.com"};
  }
}
