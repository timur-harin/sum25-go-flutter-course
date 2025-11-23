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
  bool _loading = true;
  String? _error;
  String? _name;
  String? _email;
  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    widget.userService.fetchUser().then((data) {
      setState(() {
        _name = data['name'];
        _email = data['email'];
        _loading = false;
      });
    }).catchError((_) {
      setState(() {
        _error = 'error fetching user';
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_name!),
                      const SizedBox(height: 8.0),
                      Text(_email!),
                    ],
                  ),
                ),
    );
  }
}
