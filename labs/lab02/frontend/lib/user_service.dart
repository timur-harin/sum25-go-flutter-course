class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return {
      'name': 'Jane Doe',
      'email': 'jane.doe@example.com',
      'age': '28',
    };
  }
}
