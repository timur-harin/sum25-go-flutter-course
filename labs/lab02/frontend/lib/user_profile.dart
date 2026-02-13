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
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('An error occurred: $_error'))
              : _user == null
                  ? const Center(child: Text('No user data'))
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_user!['name'] ?? '', style: const TextStyle(fontSize: 24)),
                        Text(_user!['email'] ?? '', style: const TextStyle(fontSize: 16)),
                        if (_user!['age'] != null)
                          Text('Age: ${_user!['age']}', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
    );
  }
}
