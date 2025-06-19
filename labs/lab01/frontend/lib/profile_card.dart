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
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар
            CircleAvatar(
              radius: 40,
              backgroundImage: avatarUrl != null 
                  ? NetworkImage(avatarUrl!) 
                  : null,
              child: avatarUrl == null 
                  ? Text(
                      name.isNotEmpty ? name[0] : '',
                      style: const TextStyle(fontSize: 24),
                    )
                  : null,
              backgroundColor: Colors.blue[100],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.email, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        email,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Age: $age',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}