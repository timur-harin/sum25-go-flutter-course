class UserService {
  bool fail = false;


  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}

    await Future.delayed(Duration(seconds: 1));

    if (fail) {
      throw Exception("Error in fetching user");
    }

    return {'name': "Real name", 'email': "real_email@example.su"};
  }
}
