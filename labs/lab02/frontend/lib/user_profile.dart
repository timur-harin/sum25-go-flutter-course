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
  // TODO: Fetch user info from userService (simulate for tests)

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('User Profile')),
    body: FutureBuilder<Map<String, String>>(
      future: widget.userService.fetchUser(), // async call
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('An error occurred'));
        }

        final user = snapshot.data!;
       return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(user['name'] ?? ''),
            Text(user['email'] ?? ''),
          ],
        ),
      );
      },
    ),
  );
}
}
