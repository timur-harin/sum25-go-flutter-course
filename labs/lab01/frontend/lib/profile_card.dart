import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final int age;
  final String? avatarUrl;

  const ProfileCard({
    super.key, // Suggestion from IntelliSense
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
                    (avatarUrl != null ? NetworkImage(avatarUrl!) : null),
                child: (avatarUrl != null
                    ? null
                    : Text(name.isEmpty ? "" : name[0].toUpperCase()))),
            const SizedBox(height: 16),
            Text(name.isEmpty ? '?' : name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Age: $age",
                style: const TextStyle(
                  fontSize: 16,
                )),
            const SizedBox(height: 8),
            Text(email,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// Class of a simple
class TextBox extends StatelessWidget {
  final String text;

  const TextBox(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
          color: Color.fromRGBO(0, 0, 0, 0.3),
          borderRadius: BorderRadius.all(Radius.circular(20.0)) // 20px
          ),
      child: Padding(
        padding: const EdgeInsets.all(13.77),
        child: Text(text),
      ),
    );
  }
}
