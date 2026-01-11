class UserService {
  bool fail = false;
  
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (fail) {
      throw Exception('Failed to fetch user');
    }
    
    return {
      'name': 'John Doe',
      'email': 'john.doe@example.com',
    };
  }
}
