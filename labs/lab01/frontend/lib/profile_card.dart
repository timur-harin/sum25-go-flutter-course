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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            CircleAvatar(child: profilePicture())
          ],
        ),
        Text(
          email,
          style: const TextStyle(fontWeight: FontWeight.w300),
        ),
        const SizedBox(height: 4),
        Text(
          'Age: $age',
          style: const TextStyle(fontWeight: FontWeight.w300),
        )
      ],
    );
  }

  Widget profilePicture() {
    if (avatarUrl == null) {
      return Text(name[0]);
    }
    return Image.network(
      avatarUrl!,
      width: 40,
      height: 40,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
         Text(name[0]),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      },
    );
  }

}
