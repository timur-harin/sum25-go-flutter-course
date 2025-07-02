import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String? _name;
  String? _email;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        _name = data['name'];
        _email = data['email'];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'error loading user';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _error != null
          ? Center(child: Text(_error!))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_name ?? '', style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(_email ?? '', style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
    );
  }
}
