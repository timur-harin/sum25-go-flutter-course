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

  CircleAvatar buildAvatar() {
    if (avatarUrl == null) {
      return CircleAvatar(
        radius : 50,
        child : (name == '') ? const Text('') : Text(name[0].toUpperCase())
      );
    }
    return CircleAvatar(
      radius : 50,
      backgroundImage : NetworkImage(avatarUrl!),
    );
  }

  String handleEmptyName() {
    if (name == '') return "?";
    return name;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildAvatar(),
            const SizedBox(height: 16),
           Text(
            handleEmptyName(),
            style : const TextStyle(
              fontSize : 24,
              fontWeight : FontWeight.bold
            )
           ),
            const SizedBox(height: 8),
            Text(
              "Age: $age",
              style : const TextStyle(fontSize : 16)
            ),
            const SizedBox(height: 8),
            Text(
              email,
              style : const TextStyle(
                fontSize : 16,
                color : Colors.grey
              )
            )
          ],
        ),
      ),
    );
  }
}