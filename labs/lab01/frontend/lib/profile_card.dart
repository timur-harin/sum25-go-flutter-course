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
            avatarUrl == null ? CircleAvatar(radius: 50, child: Text(name.isEmpty ? "?" : name[0].toUpperCase())) : CircleAvatar(radius: 50, backgroundImage: NetworkImage(avatarUrl!),),
            const SizedBox(height: 16),
            Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Age: $age", style: const TextStyle(fontSize: 16),),
            const SizedBox(height: 8),
            // TODO: add a Text with email and style fontSize: 16, color: Colors.grey
            Text(email, style: const TextStyle(fontSize: 16, color: Colors.grey),)
          ],
        ),
      ),
    );
  }
}
