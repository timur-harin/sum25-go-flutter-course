import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  // Widget properties with required name, email, and age and oprional - url
  final String name;
  final String email;
  final int age;
  final String? avatarUrl;

  // Widget constructor with parameters above
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
              /*
                User avatar circle with fixed radius 50,
                displayed image by provided URL,
                but if no URL provided, then with displayed uppercase first name letter
              */
              CircleAvatar(
                radius: 50,
                backgroundImage: avatarUrl != null
                    ? NetworkImage(avatarUrl!)
                    : null,
                child: avatarUrl == null
                    ? Text(
                      name.isEmpty
                      ? "?"
                      : name[0].toUpperCase(),
                      style: const TextStyle(fontSize: 40,),
                    )
                    : null
              ),
            const SizedBox(height: 16),
            // User's name field display
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    ),
                ),
            const SizedBox(height: 8),
            // User's age field display
            Text(
              'Age: $age',
              style: const TextStyle(fontSize: 16,),
            ),
            const SizedBox(height: 8),
            // User's email field display
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            
          ],
        ),
      ),
    );
  }
}
