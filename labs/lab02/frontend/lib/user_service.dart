class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    await Future.delayed(const Duration(milliseconds: 500));
    // return {'name': ..., 'email': ...}
    //throw UnimplementedError();
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}
