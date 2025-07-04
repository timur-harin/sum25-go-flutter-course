class UserService {
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    if (fail) {
      // Failure imitation
      throw Exception("Failed");
    }
    await Future.delayed(Duration.zero);

    // Correct result return imitation
    return {"name": "Alice", "email": "alice@example.com"};
  }
}
