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
    final initial = (name.isNotEmpty) ? name[0].toUpperCase() : '?';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: (avatarUrl != null && avatarUrl!.isNotEmpty)
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty)
                  ? Text(initial, style: const TextStyle(fontSize: 32))
                  : null,
            ),
            const SizedBox(height: 12),
            Text(name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 4),
            Text(email,
                style: const TextStyle(color: Colors.grey, fontSize: 16)),
            const SizedBox(height: 4),
            Text('Age: $age', style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
