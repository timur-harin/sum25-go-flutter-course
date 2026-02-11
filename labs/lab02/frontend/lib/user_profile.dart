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
  // States for user data, loading, and error
  Map<String, String>? _userData;
  bool _isLoading = true;
  String? _error;

  // Fetching user info from userService
  Future<void> _fetchUserInfo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Fetching user data from the service
      final data = await widget.userService.fetchUser();
      // If successful, then update UI state
      setState(() {
        _userData = data;
      });
    } catch (e) {
      // Updating UI state to show error message
      setState(() {
        _error = e.toString().toLowerCase();
      });
    } finally {
      /* This state executes not depending on success or failure
         Removing the loagind state in UI
      */
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  // User profile UI with loading, error, and user info
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: _isLoading
          // Loading state
          ? const Center(child: CircularProgressIndicator())
          // Error display
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Error message text
                      Text('error: $_error'),
                      const SizedBox(height: 16),
                      // Retry button to call _fetchUserInfo again
                      ElevatedButton(
                        onPressed: _fetchUserInfo,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
                // Show user profile info
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // User name display
                      Text(_userData?['name'] ?? 'Anonymous'),
                      const SizedBox(height: 8),
                      // Email display
                      Text(_userData?['email'] ?? 'Anonymous@example.com'),
                    ],
                  ),
                ),
    );
  }
}
