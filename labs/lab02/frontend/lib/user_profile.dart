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
  Map<String, String>? userData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> fetchUserInfo() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final data = await widget.userService.fetchUser();
      setState(() {
        userData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Connection error';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (error != null) {
      content = Center(child: Text(error!));
    } else if (userData != null) {
      content = Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${userData!['name']}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${userData!['email']}', style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      );
    } else {
      content = const Center(child: Text('No user data available'));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: content,
    );
  }
}
