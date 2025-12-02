class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}
    // throw UnimplementedError();

    await Future.delayed(Duration(milliseconds: 200));
    return {'name': 'Mark', 'email': 'm.borodin@gg.ru'};
  }

  
}
