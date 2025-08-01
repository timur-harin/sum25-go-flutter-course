class UserService {
  bool unsuccessful = false;
  UserService({this.unsuccessful = false});
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    // await Future.delayed(...)
    // return {'name': ..., 'email': ...}
    await Future.delayed(const Duration(milliseconds: 300));
    if (unsuccessful) throw Exception('Failed to fetch user data'); // failure imitation
    return {
      "name": "Alice",
      "email": "alice@example.com",
    };
  }
}
