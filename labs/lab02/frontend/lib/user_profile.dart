import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

class UserProfile extends StatefulWidget {
  final dynamic userService;
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
    _userFuture = _fetchUser();
  }

  Future<Map<String, String>> _fetchUser() async {
    return widget.userService.fetchUser();
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
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'An error occurred: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user['name'] ?? '', style: const TextStyle(fontSize: 24)),
                Text(user['email'] ?? '', style: const TextStyle(fontSize: 16)),
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