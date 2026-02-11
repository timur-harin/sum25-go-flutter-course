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
    late Future<Map<String, String>> _userFuture;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _userFuture = widget.userService.fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: FutureBuilder<Map<String, String>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'error: ${snapshot.error.toString().toLowerCase()}', 
              ),
            );
          }

          final userData = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData['name'] ?? '',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Text(userData['email'] ?? ''),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refreshUser,
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _refreshUser() {
    setState(() {
      _userFuture = widget.userService.fetchUser();
    });
  }

}