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
        _error = 'error: $e';
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
      return Center(child: Text(_error!));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(_user?['name'] ?? '',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        Text(_user?['email'] ?? ''),
      ],
    );
  }
}
