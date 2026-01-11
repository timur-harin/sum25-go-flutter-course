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
  String? name;
  String? email;
  bool _loading = false;
  String? _error;
  // TODO: Fetch user info from userService (simulate for tests)

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _fetchUserData();
  }

  void _fetchUserData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var data = await widget.userService.fetchUser();
      setState(() {
        name = data["name"];
        email = data["email"];
        _loading = false;
      });
    }
    catch (e) {
      setState(() {
        _loading = false;
        _error = "User info fetch error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator()
          else if (_error != null) Text(_error!)
          else Column(children: [
          Row(children: [
            Text("User Name:"),
            Text(name!)
          ],),
          Row(children: [
            Text("Email:"),
            Text(email!)
          ],)
        ],)
        ],
      )
    );
  }
}
