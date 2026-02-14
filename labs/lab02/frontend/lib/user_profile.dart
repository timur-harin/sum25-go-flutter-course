import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, String>? _userData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _userData = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error: failed to load user data';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_userData == null) {
      return const Center(child: Text('No user data'));
    }
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_userData!['name'] ?? '', style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text(_userData!['email'] ?? '', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
