import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final UserService
      userService; // Accepts a user service for fetching user info
  const UserProfile({super.key, required this.userService});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // To store the result of "widget.userService.fetchUser()"
  bool _isErr = false; // Loading error boolean
  String? _username;
  String? _usermail;
  final String _errDescr = "error"; // Rich error description

  // Loads user data
  // Purpose: to load it asyncronously
  Future<void> _loadData() async {
    try {
      // Load data
      Map<String, String> userData = await widget.userService.fetchUser();
      setState(() {
        _username = userData["name"];
        _usermail = userData["email"];
        _isErr = false;
      });
      _isErr = false;
    } catch (fetchErr) {
      setState(() {
        _username = null;
        _usermail = null;
        _isErr = true; // To render the error message
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    // Not the bast practice
    String user = "";
    if (_username != null) {
      user = _username!;
    }
    String email = "";
    if (_usermail != null) {
      email = _usermail!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
          child: Column(
        children: [
          Text(_isErr ? _errDescr : user),
          SizedBox(
            height: 20,
          ),
          // Print nothing in case of error
          Text(_isErr ? "" : email)
        ],
      )),
    );
  }
}
