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
    // TODO: Implement profile card UI

    return Card(
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          radius: 40,
          child: avatarUrl == null ? Text(name.characters.first) : null,
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            Text('Age: $age'),
          ],
        ),
      ),
    );
  }
}
