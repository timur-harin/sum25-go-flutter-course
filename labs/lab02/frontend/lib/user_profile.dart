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
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _userData;

  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _userData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('error'));
    }
    if (_userData != null) {
      final name = _userData!['name'] ?? '';
      final initial = name.isNotEmpty ? name[0].toUpperCase() : '';
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              child: Text(
                initial,
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(height: 16),
            Text('$name'),
            const SizedBox(height: 8),
            Text(
              _userData!['email'] ?? '',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }
    return const Center(child: Text('No user data available'));
  }
}
