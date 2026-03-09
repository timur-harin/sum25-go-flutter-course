import 'dart:async';

class UserService {
  bool fail = false;
  Duration simulationDelay = const Duration(milliseconds: 10);

  UserService();

  Future<Map<String, String>> fetchUser() async {
    if (fail) {
      throw Exception('Failed to fetch user data');
    }

    await Future.delayed(simulationDelay);

    return {'name': 'Alice', 'email': 'alice@example.com'};
  }

  Future<void> updateUser(Map<String, String> updates) async {
    if (fail) {
      throw Exception('Failed to update user data');
    }
    await Future.delayed(simulationDelay);
  }
}
