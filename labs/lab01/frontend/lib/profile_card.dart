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
    final displayName = name.isNotEmpty ? name : '?';
    final initialLetter = name.isNotEmpty ? name[0].toUpperCase() : '?';

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
              backgroundColor: avatarUrl == null ? Colors.lightBlue : null,
              child: avatarUrl == null
              ? Text(
                      initialLetter,
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            // TODO: add a CircleAvatar with radius 50 and backgroundImage NetworkImage(avatarUrl!) if url is not null and text name[0].toUpperCase() if url is null
            
            const SizedBox(height: 16),
            name != '' ?
            Text(
              name,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            )
            : Text(
                '',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            // TODO: add a Text with name and style fontSize: 24, fontWeight: FontWeight.bold
           
            const SizedBox(height: 8),
            Text(
              'Age: $age',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            // TODO: add a Text with Age: $age and style fontSize: 16
           
            const SizedBox(height: 8),
            Text(
              email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            // TODO: add a Text with email and style fontSize: 16, color: Colors.grey
            
          ],
        ),
      ),
    );
  }
}
