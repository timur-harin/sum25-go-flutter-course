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

  // Fetch user info from userService (simulate for tests)
  Future<void> _fetchUser() async {
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error loading user data';
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUser();
    // TODO: Fetch user info and update state
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
     return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _userData != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_userData!['name']!),
                          Text(_userData!['email']!),
                        ],
                      ),
                    )
                  : const Center(child: Text('No user data')),
    );
  }
}
