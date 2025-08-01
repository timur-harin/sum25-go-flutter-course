// import 'package:lab02_chat/user_profile.dart';

class UserService {
  Future<Map<String, String>> fetchUser() async {
    await Future.delayed(Duration(milliseconds: 100));
    return {
      'name': 'Vladimir',
      'email': 'vladimir.putin@kremlin.ru',
    };
  }
}