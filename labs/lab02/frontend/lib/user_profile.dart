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
  String? name;
  String? email;
  bool loading = true;
  String? error = "error";


  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<Map<String, String>?> fetchUserData() async {
    Map<String, String>? userData;
    try {
      userData = await widget.userService.fetchUser();
      setState(() {
        name = userData!["name"];
        email = userData["email"];
        loading = false;
        error = null;
      });
    }
    catch(e) {
      setState(() {
        name = null;
        email = null;
      });
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: Center(
        child: Column(
          children: [
            Text(
              loading == true ? error! : name!
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              loading == true ? "" : email!
            )
          ],
        )
      ),
    );
  }
}
