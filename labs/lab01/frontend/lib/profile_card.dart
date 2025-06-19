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
      child: 
        Row(
          children: [
            Text("Counter"),
            CircleAvatar(
              radius: 24,
              child: Text( name.isNotEmpty ? name[0] : '?'),
            ),
            Text(name),
            Text(email),
            Text("Age: " + age.toString())
          ]
      ),
    );
  }
}
