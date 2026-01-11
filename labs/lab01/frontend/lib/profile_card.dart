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
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              onBackgroundImageError: avatarUrl != null
                  ? (exception, stackTrace) {
                      print('Image load error: $exception');
                    }
                  : null,
              child: avatarUrl == null
                  ? Text(name.isNotEmpty ? name[0] : '?')
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // TODO: add a Text with Age: $age and style fontSize: 16
            Text("Age: $age", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
