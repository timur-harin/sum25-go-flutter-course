import 'dart:async';

class UserService {
  // TODO: Simulate fetching user data for tests
  // Add simulation flag for failure as implied by tests
  bool fail = false;

  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(milliseconds: 10));
    if (fail) {
      throw Exception('Simulated fetch user failure');
    }
    return {'name': 'Alice', 'email': 'alice@example.com'};
  }
}