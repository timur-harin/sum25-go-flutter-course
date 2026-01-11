import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  Map<String, String>? _userData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    setState(() => _isLoading = true);
    try {
      final userData = await widget.userService.fetchUser();
      setState(() {
        _userData = userData;
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          'error: $_error', // Fixed: lowercase 'error'
          style: const TextStyle(color: Colors.deepPurpleAccent),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_userData?['name'] != null)
              Text(
                _userData!['name']!,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            const SizedBox(height: 16),
            if (_userData?['email'] != null)
              Text(
                _userData!['email']!,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _fetchUserData,
              child: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}