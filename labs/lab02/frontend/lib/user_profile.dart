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
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await widget.userService.fetchUser();
      setState(() {
        _user = user;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      _loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
          child: _loading
              ? CircularProgressIndicator(
                  color: Colors.greenAccent,
                )
              : _error != null
                  ? Text("error: $_error!",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red))
                  : _user != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _user!["name"] ?? '',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _user!['email'] ?? '',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        )
                      : Text("?")),
    );
  }
}
