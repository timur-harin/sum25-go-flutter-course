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
  String? _name;
  String? _email;
  bool _isLoading = true;
  String? _errorMessage;

  // TODO: Fetch user info from userService (simulate for tests)
    void _loadUserInfo() async {
    try {
      final user = await widget.userService.fetchUser();
      setState(() {
        _name = user['name'];
        _email = user['email'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // TODO: Fetch user info and update state
    _loadUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (_errorMessage != null) {
      return Center(child: Text('error: $_errorMessage'));
    } else {
return Scaffold(
    appBar: AppBar(title: const Text('User Profile')),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage != null
            ? Center(child: Text('error: $_errorMessage'))
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name ?? '', style: const TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(_email ?? '', style: const TextStyle(fontSize: 18)),
                  ],
          ),
        ),
      );
    }
  }
}