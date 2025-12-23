class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(Duration(milliseconds: 10));
    return {
      'name': 'Amir',
      'email': 'amir_gg_wp@hello_world.com',
    };
  }
}
