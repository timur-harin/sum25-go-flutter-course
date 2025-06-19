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
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      child: Card(
        child: Column(
          spacing: 20,
          children: [
            avatarUrl != null && avatarUrl!.isNotEmpty
                ? const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey,
                )
                : CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey,
                    child: Text(name[0]),
                  ),
            Text(name),
            Text("Age: $age"),
            Text(email, style: const TextStyle(color: Colors.grey))
          ],
        )
      )
    );
  }
}
