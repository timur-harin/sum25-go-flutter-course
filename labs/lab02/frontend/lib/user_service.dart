class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(seconds: 1));
    return {'name': 'Aleksei Fominykh', 'email': 'a.fominykh@innopolis.university'};
  }
}
