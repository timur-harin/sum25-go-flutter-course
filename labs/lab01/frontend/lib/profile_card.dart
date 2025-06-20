import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final int age;
  final String? avatarUrl;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.age,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
        Text(name),
        Text(email),
        Text("Age: $age"),
        const CircleAvatar(child: Text("J"),),
      ]
      );
  }
}
