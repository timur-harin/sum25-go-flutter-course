class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
    'name': 'Danil Malygin',
    'email': 'd.malygin@innopolis.university',
    };
  }

  Future<void> updateUser({
    required String name,
    required String email,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}