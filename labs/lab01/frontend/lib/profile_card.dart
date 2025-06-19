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
    return Container(
      child: Card(
        child: ListTile(
          leading: avatarUrl != null
              ? CircleAvatar(
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.network(
                avatarUrl!,
                fit: BoxFit.cover,
                width: 40,
                height: 40,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.person);
                },
              ),
            ),
          )
              : const CircleAvatar(child: Icon(Icons.person)),
          title: Text(name),
          subtitle: Text(email),
          trailing: Text("Age: $age"),
        ),
      ),
    );
  }
}
