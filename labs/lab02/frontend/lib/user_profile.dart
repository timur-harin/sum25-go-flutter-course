import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final UserService userService; // Accepts a user service for fetching user info
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // TODO: Add state for user data, loading, and error
  // TODO: Fetch user info from userService (simulate for tests)
  bool isLoading = true;
  bool hasError = false;
  Map<String, String>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        userInfo = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    Widget content;

    if (isLoading) {
      content = const CircularProgressIndicator();
    } else if (hasError) {
      content = const Text('error');
    } else if (userInfo != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${userInfo!['name']}', style: const TextStyle(fontSize: 18)),
          Text('${userInfo!['email']}', style: const TextStyle(fontSize: 16)),
        ],
      );
    } else {
      content = const Text('No user data available.');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(child: content),
    );
  }
}
