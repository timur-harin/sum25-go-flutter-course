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
  Map<String, String>? _username;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.userService.fetchUser().then((data) {
      setState(() {
        _username = data;
        _isLoading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = 'error: $e';
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_username?['name'] ?? '', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(_username?['email'] ?? ''),
      ],
    );
  }
}
