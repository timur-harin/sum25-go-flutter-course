import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;

  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  bool _loading = true;
  String? _error;
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await widget.userService.fetchUser();
      setState(() {
        _nameController.text = user['name']!;
        _emailController.text = user['email']!;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'error: Failed to load user';
        _loading = false;
      });
    }
  }

  Future<void> _updateUser() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.userService.updateUser(
        name: _nameController.text,
        email: _emailController.text,
      );
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error: Failed to update user';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _loading
          ? const Center(child: Text('Loading...'))
          : _error != null
          ? Center(
        child: Text(
          _error!,
          key: const Key('errorText'),
          style: const TextStyle(color: Colors.red),
        ),
      )
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('nameField'),
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('emailField'),
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _error!,
                  key: const Key('errorText'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ElevatedButton(
              key: const Key('saveButton'),
              onPressed: _loading ? null : _updateUser,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
