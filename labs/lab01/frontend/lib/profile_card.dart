import 'package:flutter/material.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final int age;
  final String? avatarUrl;

  const ProfileCard({
    super.key,  // Suggestion from IntelliSense
    required this.name,
    required this.email,
    required this.age,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextBox(name), // display the name
        const SizedBox(height: 10.0), // margin top-bottom
        TextBox(email), // display the email
        const SizedBox(height: 10.0), // to "split" the "TextBox"es
        const SizedBox(height: 10.0),
        TextBox("Age: $age"), // display the age
        CircleAvatar(
          child: avatarUrl != null ? null : Text(name[0]),
        ),
      ]
      ),
    );
  }
}

// Class of a simple 
class TextBox extends StatelessWidget {
  final String text;

  const TextBox(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return  DecoratedBox(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(0, 0, 0, 0.3),
              borderRadius: BorderRadius.all(Radius.circular(20.0)) // 20px
            ),
            child: Padding(
              padding: const EdgeInsets.all(13.77),
              child: Text(text),
            ),
          );
  }
}
