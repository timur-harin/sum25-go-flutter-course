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
  String? _userName;
  String? _email;
  bool _isLoading = false;
  String? _errorMessage;
  // TODO: Fetch user info from userService (simulate for tests)


  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _isLoading = true;
    widget.userService.fetchUser().then((userData) {
      setState(() {
        _userName = userData['name'];
        _email = userData['email'];
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _errorMessage = 'error: failed to load user';
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
            : _errorMessage != null
            ? Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_userName ?? ''),
            const SizedBox(height: 8),
            Text(_email ?? ''),
          ],
        ),
      ),
    );
  }
}
