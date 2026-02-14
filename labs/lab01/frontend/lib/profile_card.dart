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
              child: avatarUrl != null ? null : 
              Text(name.isEmpty ? "" : name[0].toUpperCase())
            ),
            
            const SizedBox(height: 16),
            Text(
              name.isEmpty ? '?' : name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24
              )
            ),
           
            const SizedBox(height: 8),
            Text(
              "Age: $age",
              style: const TextStyle(
                fontSize: 16
              )
            ),
           
            const SizedBox(height: 8),
            Text(
              email,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey
              )
            ),
          ],
        ),
      ),
    );
  }
}