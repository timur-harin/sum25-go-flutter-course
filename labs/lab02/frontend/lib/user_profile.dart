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
  bool _loading = true;
  String? _error;
  Map<String, String>? _user;

  @override
  void initState() {
    super.initState();
    widget.userService.fetchUser().then((data) {
      setState(() {
        _user = data;
        _loading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = 'error: Failed to load user info';
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('User Profile')),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_user?['name'] ?? '', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 10),
            Text(_user?['email'] ?? '', style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
