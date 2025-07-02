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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration:
          const BoxDecoration(color: Color.fromARGB(255, 179, 178, 178)),
      child: Card(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null ? Text(name == '' ? "" : name[0].toUpperCase() ) : null,
          ),
           const SizedBox(height: 16),
          Text(
            name == '' ? '?' : name,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Age: $age",
            style: TextStyle(fontSize: 16),
          ),
                    const SizedBox(height: 8),
          Text(
            email,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          
        ],
      ),
      )
    );
  }
}
