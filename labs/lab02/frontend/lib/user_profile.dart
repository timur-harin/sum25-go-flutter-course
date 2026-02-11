import 'package:flutter/material.dart';
import 'package:lab02_chat/user_service.dart';

class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<Map<String, String>> _userFuture;
  final String _errorDescription = "Profile loading error";

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<Map<String, String>> _fetchUserData() async {
    try {
      return await widget.userService.fetchUser();
    } catch (e) {
      // Return empty map to indicate error
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Map<String, String>>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                  return RichText(text : TextSpan(text : _errorDescription));
                }

                final userData = snapshot.data!;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(userData['name'] ?? 'No name'),
                    const SizedBox(height: 8),
                    Text(userData['email'] ?? 'No email'),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}