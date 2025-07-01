import 'package:flutter/material.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final dynamic userService; // Accepts a user service for fetching user info
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<Map<String, String>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
  }

  Future<Map<String, String>> _fetchUser() async {
    // TODO: Fetch user info from userService
    throw UnimplementedError();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: FutureBuilder<Map<String, String>>(
        future: _userFuture,
        builder: (context, snapshot) {
          // TODO: Display user info, loading, and error states
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('An error occurred: \\${snapshot.error}'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user['name'] ?? '', style: const TextStyle(fontSize: 24)),
                Text(user['email'] ?? '', style: const TextStyle(fontSize: 16)),
                // TODO: Add more user fields if needed
              ],
            );
          } else {
            return const Center(child: Text('No user data'));
          }
        },
      ),
    );
  }
}
