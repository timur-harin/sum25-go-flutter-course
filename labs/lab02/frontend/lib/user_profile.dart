import 'package:flutter/material.dart';
import 'user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({super.key, required this.userService});

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
    _fetchUser();
  }

  void _fetchUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = await widget.userService.fetchUser();
      setState(() => _userData = user);
    } catch (e) {
      setState(() => _error = 'An error occurred');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_userData!['name']!),
          const SizedBox(height: 10),
          Text(_userData!['email']!),
        ],
      ),
    );
  }
}
