import 'dart:async';

class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(const Duration(milliseconds: 10));
    return {
      'name': 'Ruslan Nasibullin',
      'email': 'ru.nasibullin@innopolis.university',
    };
  }
}
