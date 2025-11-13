class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(milliseconds: 10));
    // TODO: return {'name': ..., 'email': ...}
    return {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
    };
  }
}
