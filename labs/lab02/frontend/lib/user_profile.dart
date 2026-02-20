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
  Map<String, String>? userData; 
  bool isLoading = true;        
  String? error;
  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _fetchUser(); 
  }
  Future<void> _fetchUser() async {
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() 
            : error != null
                ? Text('An error occurred: $error') 
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(userData!['name']!), 
                      Text(userData!['email']!), 
                    ],
                  ),
      ),
    );
  }
}