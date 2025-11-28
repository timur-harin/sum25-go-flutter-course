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
  Map<String, String>? _userData;
  bool _isLoading = true;
  String? _error;
  // TODO: Fetch user info from userService (simulate for tests)

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _userData = null;
    });
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error fetching user: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Center(
      child: _isLoading
          ? const CircularProgressIndicator()
          : _error != null
          ? const Text(
        'error: Failed to load user profile.', // Changed to lowercase 'e'
        style: TextStyle(color: Colors.red),
      )
          : _userData != null
          ? Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_userData!['name']!,
              style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(_userData!['email']!,
              style: const TextStyle(fontSize: 16)),
        ],
      )
          : const Text('No user data available'),
    );
  }
}