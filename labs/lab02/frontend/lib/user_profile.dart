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
  Map<String, String>? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.userService.fetchUser().then((data) {
      setState(() {
        _user = data;
        _loading = false;
      });
    }).catchError((err) {
      setState(() {
        _error = 'error: $err';
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_user?['name'] ?? '', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(_user?['email'] ?? ''),
      ],
    );
  }
}
