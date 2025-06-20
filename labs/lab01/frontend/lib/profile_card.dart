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
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundImage:
                avatarUrl != null ? NetworkImage(avatarUrl!) : null,
            onBackgroundImageError: avatarUrl != null
                ? (exception, stackTrace) {
                    print('Image load error: $exception');
                  }
                : null,
            child:
                avatarUrl == null ? Text(name.isNotEmpty ? name[0] : '') : null,
          ),
          SizedBox(height: 8),
          Text(name, style: TextStyle(fontSize: 20)),
          Text(email, style: TextStyle(fontSize: 16)),
          Text("Age: $age", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
