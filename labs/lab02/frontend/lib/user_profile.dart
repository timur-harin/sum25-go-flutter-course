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
  Map<String, String>? _userData;
  bool _isLoading = true;
  String? _error;


  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    widget.userService.fetchUser().then((data) {
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Connection error: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${_userData?['name'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 10),
                      Text('${_userData?['email'] ?? 'Unknown'}',
                          style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
    );
  }
}
