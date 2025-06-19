// profile_card.dart
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
    Widget avatarChild;

    if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      // Используем Image.network с errorBuilder
      avatarChild = Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        // Этот билдер сработает, когда тест вернет ошибку 400
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        // Можно добавить индикатор загрузки для красоты
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    } else {
      // Запасной вариант, если URL не предоставлен
      avatarChild = Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Card(
      elevation: 2.0,
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.primary,
          // Оборачиваем дочерний виджет в ClipOval, чтобы сделать его круглым
          child: ClipOval(
            child: SizedBox.fromSize(
              size: const Size.fromRadius(30),
              child: avatarChild,
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(email),
            Text('Age: $age'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}