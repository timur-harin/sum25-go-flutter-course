class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(seconds: 2));
    return {'name': 'Aleksey', 'email': 'a.chegaev@innopolis.university'};
  }
}
