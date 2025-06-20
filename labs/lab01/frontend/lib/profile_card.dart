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
        Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 40
          )
        ),
        Text(
          email,
          style: const TextStyle(
            fontSize: 30
          )
        ),
        Text(
          "Age: $age",
          style: const TextStyle(
            fontSize: 30
          )
        ),
        CircleAvatar(
          radius: 70,
          child: avatarUrl != null
            ? null
            : Text(
              name[0]
            )
        )
      ],
    );
  }
}