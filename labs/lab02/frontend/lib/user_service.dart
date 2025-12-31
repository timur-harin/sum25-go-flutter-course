class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(milliseconds: 10));
    return {
      'name': 'Alice',
      'email': 'alice@example.com',
    };
  }
  Future<String> getUser() async {
    final userData = await fetchUser();
    return userData['name'] ?? 'Unknown';
  }
}
