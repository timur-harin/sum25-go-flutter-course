
import 'package:flutter/material.dart';
import 'user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;

  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _loading = true;
  String? _error;
  Map<String, String>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _user = data;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('User Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text('User Profile')),
        body: Center(child: Text('error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('User Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_user!['name']!),
            const SizedBox(height: 8),
            Text(_user!['email']!),
          ],
        ),
      ),
    );
  }
}
