import 'dart:math';

import 'dart:async';

class UserService {
  Future<Map<String, String>> fetchUser() async {
    // TODO: Simulate fetching user data for tests
    await Future.delayed(Duration(milliseconds: 300));
    // return {'name': 'Userasas', 'email': "some@mail.com"}
    return {
      'name': 'User${Random().nextInt(1000)}',
      'email': 'user${Random().nextInt(1000)}@example.com', // Случайный email}
    };
    // throw UnimplementedError();
  }
}