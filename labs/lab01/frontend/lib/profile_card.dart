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
<<<<<<< HEAD
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: add a CircleAvatar with radius 50 and backgroundImage NetworkImage(avatarUrl!) if url is not null and text name[0].toUpperCase() if url is null
            
            const SizedBox(height: 16),
            // TODO: add a Text with name and style fontSize: 24, fontWeight: FontWeight.bold
           
            const SizedBox(height: 8),
            // TODO: add a Text with Age: $age and style fontSize: 16
           
            const SizedBox(height: 8),
            // TODO: add a Text with email and style fontSize: 16, color: Colors.grey
            
=======
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage:
                  avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      name.isNotEmpty ? name[0] : '?',
                      style: const TextStyle(fontSize: 24, color: Colors.white),
                    )
                  : null,
              backgroundColor: avatarUrl == null ? Colors.blueGrey : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(email),
                  const SizedBox(height: 4),
                  Text('Age: $age'),
                ],
              ),
            ),
>>>>>>> 8441780 (lab01 solution)
          ],
        ),
      ),
    );
  }
}
