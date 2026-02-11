class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(milliseconds: 50));
    return {'name': "Georgy_hehe", 'email': "georgy_funny@mail.com"};
  }
}
