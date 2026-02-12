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
  late Future<Map<String, String>> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.userService.fetchUser();
  }

  // Optionally, you can add a method to refresh user info:
  Future<void> _refreshUser() async {
    setState(() {
      _userFuture = widget.userService.fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUser,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: FutureBuilder<Map<String, String>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading user info',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user['name'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 10),
                  Text('Email: ${user['email'] ?? 'N/A'}',
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No user data'));
          }
        },
      ),
    );
  }
}
