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
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$name'
          ),
          Text(
            '$email'
          ),
          Text(
            'Age: $age'
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200]
          )
        ],
      ),
    );
  }
  }
