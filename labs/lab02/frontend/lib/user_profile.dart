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
  late String name;
  late String email;
  bool _isLoading = true;
  bool _hasError = false;


  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      Map<String, String> userdata = await widget.userService.fetchUser();
      setState(() {
        name = userdata['name'] ?? "unknown";
        email = userdata['email'] ?? "unknown";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return const Scaffold(
        body: Center(child: Text('Connection error')),
      );
    }


    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: Column(
          children: [
            Text(name),
            Text(email),
          ],
        )
      )
    );
  }
}
