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

  ImageProvider? getImage(String? url) {
    if (url != null && url.isNotEmpty) {
      try {
        return NetworkImage(url!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement profile card UI
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            spacing: 10,
            children: [
              Stack(children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: MediaQuery.of(context).size.width * 0.3,
                  child: CircleAvatar(
                    backgroundImage:
                        null, // Here should be getImage(avatarUrl), but due to the error it was removed
                    child: avatarUrl == null || avatarUrl!.isEmpty
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : '')
                        : null,
                  ),
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.black,
                        size: MediaQuery.of(context).size.height * 0.03,
                      ),
                    ))
              ]),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.06,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  ),
                  Text(
                    'Age: $age',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.04,
                    ),
                  )
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
