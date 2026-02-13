class UserService {
  Future<Map<String, String>> fetchUser() async {
    return await Future.delayed(const Duration(seconds: 1), () {
      return {'name': 'John Doe', 'email': 'john@example.com'};
    });
  }
}
