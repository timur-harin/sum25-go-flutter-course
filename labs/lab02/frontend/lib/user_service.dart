class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(milliseconds: 1));
    return {'name': 'Valera', 'email': 'valera_nagibator@vobla.com'};
  }
}

