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
    return const Card(
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // TODO: add a CircleAvatar with radius 50 and backgroundImage NetworkImage(avatarUrl!) if url is not null and text name[0].toUpperCase() if url is null
            
            SizedBox(height: 16),
            // TODO: add a Text with name and style fontSize: 24, fontWeight: FontWeight.bold
           
            SizedBox(height: 8),
            // TODO: add a Text with Age: $age and style fontSize: 16
           
            SizedBox(height: 8),
            // TODO: add a Text with email and style fontSize: 16, color: Colors.grey
            
          ],
        ),
      ),
    );
  }
}
