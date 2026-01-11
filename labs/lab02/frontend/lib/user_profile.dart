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
  // TODO: Add state for user data, loading, and error
  Map<String, String>? userData;
  bool loading = true;
  String? error;
  // TODO: Fetch user info from userService (simulate for tests)

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  Future<void> loadUser() async {
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        userData = data;
        loading = false;
      });
    } catch (err) {
      setState(() {
        error = 'error: ${err.toString()}';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info

    Widget body;
    if (loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      body = Center(child: Text('error: ${error}',));
    } else {
      body = Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                userData!['name'] ?? '',
              ),
              const SizedBox(height: 8),
              Text(
                userData!['email'] ?? '',
              ),
            ],
          ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: body,
    );
  }
}
