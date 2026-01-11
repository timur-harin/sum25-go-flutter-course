import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final UserService
      userService; // Accepts a user service for fetching user info
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _loading = true;
  Map<String, String>? _userData;
  Exception? _error;

  // TODO: Add state for user data, loading, and error
  // TODO: Fetch user info from userService (simulate for tests)

  @override
  void initState() {
    super.initState();
    widget.userService.fetchUser().then((data) {
      _userData = data;
      _loading = false;
    }).catchError((error) {
      _loading = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(
            child: Text(_error.toString(),
                style: const TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Column(
        children: [
          Text(_userData?['name'] ?? '', style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 10),
          Text(_userData?['email'] ?? '', style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
