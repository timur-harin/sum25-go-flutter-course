import 'package:flutter/material.dart';
import 'user_service.dart';

/// UserProfile displays and allows updating user information.
class UserProfile extends StatefulWidget {
  final UserService userService;
  const UserProfile({Key? key, required this.userService}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Future<Map<String, String>> _userFuture;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  void _fetchUser() {
    setState(() {
      _userFuture = widget.userService.fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    // FIX: Wrap the content in a Scaffold to provide the necessary Material context.
    return Scaffold(
      body: FutureBuilder<Map<String, String>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('An error occurred: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchUser,
                      child: const Text('Retry'),
                    )
                  ],
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            final user = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  ListTile(
                    leading: const Icon(Icons.person, size: 40),
                    title: Text(user['name'] ?? 'N/A',
                        style: Theme.of(context).textTheme.titleLarge),
                    subtitle: const Text('Name'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.email, size: 40),
                    title: Text(user['email'] ?? 'N/A',
                        style: Theme.of(context).textTheme.titleLarge),
                    subtitle: const Text('Email'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('No user data available.'));
        },
      ),
    );
  }
}