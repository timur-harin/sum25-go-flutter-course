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
    }).catchError((err) {
      setState(() {
        _error = err.toString();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(
                    'error: $_error',
                    style: const TextStyle(color: Colors.red),
                  )
                : _userData != null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Name:'),
                          Text(
                            _userData!['name'] ?? '',
                            key: const Key('nameText'),
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 8),
                          const Text('Email:'),
                          Text(
                            _userData!['email'] ?? '',
                            key: const Key('emailText'),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      )
                    : const Text('No user data.'),
      ),
    );
  }
}