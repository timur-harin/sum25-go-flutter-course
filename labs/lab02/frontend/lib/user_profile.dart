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
  // State for user data, loading, and error
  Map<String, String>? _userData;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Fetch user info and update state
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // Simulate fetching user info from userService
      final user = await widget.userService.getUser();
      setState(() {
        _userData = user;
      });
    } catch (e) {
      setState(() {
        // Show error message containing 'error:' for test compatibility
        _error = e.toString().contains('error:') ? e.toString() : 'error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)))
              : _userData == null
                  ? const Center(child: Text('No user data'))
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show name as a plain Text widget for test compatibility
                          Text(_userData!['name'] ?? '',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(_userData!['email'] ?? '',
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 8),
                          Text(_userData!['id'] ?? '',
                              style: const TextStyle(fontSize: 18)),
                        ],
                      ),
                    ),
    );
  }
}
