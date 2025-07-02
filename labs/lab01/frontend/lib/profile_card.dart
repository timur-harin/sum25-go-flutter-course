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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            child: avatarUrl == null ? Text(name[0]) : null,
          ),
          const Padding(padding: EdgeInsets.only(top: 20)),
          Text(
            name,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          Text(
            email,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            "Age: $age",
            style: Theme.of(context).textTheme.bodyMedium,
          )
        ],
      ),
    );
  }
}
