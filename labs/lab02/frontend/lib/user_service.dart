class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(microseconds: 500));
    return {'name': "John", 'email': "john@email.com"};
  }
}
