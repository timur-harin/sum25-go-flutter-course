import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final int age;
  final String? avatarUrl;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.email,
    required this.age,
    this.avatarUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Implement profile card UI
    return Scaffold(
      appBar: AppBar(
          title: Text("lol")
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 36),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null ? Text(name[0]) : null,
                ),
              ]
            ),
                const Text("Username:"),
                Text(
                  name,
                ),
                const SizedBox(height: 20,),
                const Text("Email:"),
                Text(
                  email,
                ),
                const SizedBox(height: 20,),
                const SizedBox(height: 4),
                Text(
                    'Age: $age'
                )
              ],
        ),
      ),
    );
  }
}
