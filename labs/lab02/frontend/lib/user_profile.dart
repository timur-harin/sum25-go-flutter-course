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
  String? _error;


  @override
  void initState() {
    super.initState();

    _fetchUser();
  }

  void _fetchUser() {
    setState(() {
      _error = null;
      _userFuture = widget.userService.fetchUser().catchError((e) {
        setState(() {
          _error = e.toString();
        });
        throw e;
      });
    });
  }

  void _updateUser(Map<String, String> updatedData) async {
    setState(() {
      _error = null;
    });

    try {
      await widget.userService.updateUser(updatedData);
      _fetchUser();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build user profile UI with loading, error, and user info
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _fetchUser,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : FutureBuilder<Map<String, String>>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: Text('No user data.'));
                }

                final data = snapshot.data!;
                final nameController =
                    TextEditingController(text: data['name'] ?? '');
                final emailController =
                    TextEditingController(text: data['email'] ?? '');

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'User Info',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          _updateUser({
                            'name': nameController.text,
                            'email': emailController.text,
                          });
                        },
                        child: const Text('Save Changes'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
