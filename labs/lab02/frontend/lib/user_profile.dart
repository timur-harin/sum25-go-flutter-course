import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

// UserProfile displays and updates user info
class UserProfile extends StatefulWidget {
  final UserService userService; // Accepts a user service for fetching user info
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  // TODO: Add state for user data, loading, and error
  // TODO: Fetch user info from userService (simulate for tests)

  Map<String, String>? _user;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _user = data;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_user != null) {
  body = Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // тест ищет именно Text("Alice"), а не "Name: Alice"
        Text(
          _user!['name']!,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          _user!['email']!,
          style: const TextStyle(fontSize: 16),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: _loadUser,
          icon: const Icon(Icons.refresh),
          label: const Text('Refresh'),
        ),
      ],
    ),
  );
} else if (_error != null) {
  body = Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // тест ищет 'error:' в lower-case
        Text('error: $_error', style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 12),
        ElevatedButton(onPressed: _loadUser, child: const Text('Retry')),
      ],
    ),
  );
} else {
      body = Center(
        child: ElevatedButton(onPressed: _loadUser, child: const Text('Load Profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: body,
    );
  }
}
