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
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 225, 199, 0),
            Color.fromARGB(255, 221, 0, 213),
          ],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
        border: Border.all(
          color: Color.fromARGB(255, 39, 39, 39)
        ),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.all(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TODO: add a CircleAvatar with radius 50 and backgroundImage NetworkImage(avatarUrl!) if url is not null and text name[0].toUpperCase() if url is null
              CircleAvatar(
                radius: 50,
                backgroundImage: avatarUrl!=null ? NetworkImage(avatarUrl!) : null,
                child: avatarUrl==null ? Text(name.isNotEmpty ? name[0].toUpperCase() : "?") : null,
              ),
              const SizedBox(height: 16),
              // TODO: add a Text with name and style fontSize: 24, fontWeight: FontWeight.bold
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold
                )
              ),
             
              const SizedBox(height: 8),
              // TODO: add a Text with Age: $age and style fontSize: 16
              Text(
                "Age: $age",
                style: const TextStyle(
                  fontSize: 16,
                )
              ),
             
              const SizedBox(height: 8),
              // TODO: add a Text with email and style fontSize: 16, color: Colors.grey
              Text(
                email,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
