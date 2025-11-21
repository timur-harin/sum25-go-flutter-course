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
  Map<String, String>? _user;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _loading = true;
    widget.userService.fetchUser().then((user) {
      setState(() {
        _user = user;
        _loading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = e.toString();
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
              ? Center(child: Text('error: $_error'))
              : _user == null
                  ? const Center(child: Text('no user data'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_user!['name'] ?? '', style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 8),
                          Text(_user!['email'] ?? '', style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      ),
                    ),
    );
  }
}
