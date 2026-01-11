import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final int age;
  final String email;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.age,
    required this.email,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isWide = constraints.maxWidth > 350;
            return isWide
                ? Row(
              children: [
                _avatar(theme),
                const SizedBox(width: 20),
                _info(theme),
              ],
            )
                : Column(
              children: [
                _avatar(theme),
                const SizedBox(height: 20),
                _info(theme),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _avatar(ThemeData theme) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: theme.textTheme.headlineLarge,
      ),
    );
  }

  Widget _info(ThemeData theme) {
    final textStyle = theme.textTheme.bodyLarge;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: \$name', style: textStyle),
          const SizedBox(height: 8),
          Text('Age: \$age', style: textStyle),
          const SizedBox(height: 8),
          Text('Email: \$email', style: textStyle),
        ],
      ),
    );
  }
}