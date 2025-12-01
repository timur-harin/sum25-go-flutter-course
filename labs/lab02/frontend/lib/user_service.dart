class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(seconds: 1));
    return {
      'name': 'John CENA',
      'email': 'johnCENA@gmail.com',
    };
  }

  Future<void> updateUser(Map<String, String> updatedData) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (updatedData['name']?.isEmpty ?? true) {
      throw UnimplementedError();
    }

  }
}
