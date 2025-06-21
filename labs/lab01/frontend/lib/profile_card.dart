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
    String initials() {
      final trimmed = name.trim();
      if (trimmed.isEmpty) return '?';
      return trimmed[0].toUpperCase();
    }

    final hasUrl = avatarUrl != null && avatarUrl!.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey.shade200,
            child: hasUrl
                ? ClipOval(
                    child: Image.network(
                      avatarUrl!.trim(),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        // если не загрузилось, показываем инициалы
                        return Center(
                          child: Text(
                            initials(),
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                : Text(
                    initials(),
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(name),
          Text(email),
          Text('Age: $age'),
        ],
      ),
    );
  }
}