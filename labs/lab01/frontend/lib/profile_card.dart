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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("?"),
        Text("J"),
        Container(
          child: Card(
            child: ListTile(
              leading: avatarUrl != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(avatarUrl!),
                onBackgroundImageError: (error, stackTrace) {
                  return;
                },
                child: null,
              )
                  : const CircleAvatar(child: Icon(Icons.person)),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),),
              subtitle: Text(email, style: TextStyle(color: Colors.grey),),
              trailing: Text("Age: $age"),
            ),
          ),
        )
      ],
    );
  }
}