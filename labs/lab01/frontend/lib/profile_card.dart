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
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
               child: avatarUrl == null 
               ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 40, color: Colors.white),
               )
               : null,
            ),
            const SizedBox(height: 16),
            // TODO: add a Text with name and style fontSize: 24, fontWeight: FontWeight.bold
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // TODO: add a Text with Age: $age and style fontSize: 16
            Text(
              'Age: $age',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            // TODO: add a Text with email and style fontSize: 16, color: Colors.grey
            Text(
              email, 
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
