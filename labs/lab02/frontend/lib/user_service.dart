class UserService {
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    if (fail) {
      throw Exception('Failed to fetch user data');
    }
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    return {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
    };
  }
}
