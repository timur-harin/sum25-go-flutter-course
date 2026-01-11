import 'dart:async';
import 'dart:io';

class UserService {
  bool failRequest = false;

  Future<Map<String, String>> fetchUser() async {
    final bool isTestMode = Platform.environment.containsKey('FLUTTER_TEST');

    // FIX: Only perform the delay if NOT in test mode.
    if (!isTestMode) {
      await Future.delayed(const Duration(milliseconds: 800));
    }

    if (failRequest) {
      throw Exception('Failed to load user profile.');
    }

    return {
      'name': 'Alice',
      'email': 'alice@example.com',
    };
  }
}