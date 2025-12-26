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
  Map<String, String>? user;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        user = data;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'An error occurred: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (loading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = Center(
        child: Text(
          error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    } else if (user != null) {
      content = Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(user!['name'] ?? '', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(user!['email'] ?? '', style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    } else {
      content = const Center(child: Text('No user data'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: content,
    );
  }
}
