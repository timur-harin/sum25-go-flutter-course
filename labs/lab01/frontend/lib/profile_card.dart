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
      child: Column(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundImage: avatarUrl != null ? null : null,
            child: avatarUrl == null 
                ? Text(name.isEmpty ? '?' : name[0])
                : null,
          ),
          Text(name),
          Text(email),
          Text('Age: $age'),
        ],
      ),
    );
  }
}