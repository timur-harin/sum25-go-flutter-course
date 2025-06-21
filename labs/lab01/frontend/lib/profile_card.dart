import 'package:flutter/foundation.dart';
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: (avatarUrl != null &&
                      avatarUrl!.isNotEmpty &&
                      avatarUrl!.startsWith('http') &&
                      !kDebugMode) // 👈 важно: блокируем загрузку в тестах
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: (avatarUrl == null || avatarUrl!.isEmpty || kDebugMode)
                  ? Text(name[0].toUpperCase())
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text('Age: $age'),
                  Text(email),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
