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
  late Future<Map<String, String>> _futureUser;


  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _futureUser = widget.userService.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: FutureBuilder<Map<String, String>>(
        future: _futureUser,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Loading state
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Error state
            return Center(child: Text('error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Success state: display name and email
            final data = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['name'] ?? ''),
                  const SizedBox(height: 8),
                  Text(data['email'] ?? ''),
                ],
              ),
            );
          } else {
            // Fallback for unexpected state
            return const Center(child: Text('No user data available'));
          }
        },
      ),
    );
  }
}
