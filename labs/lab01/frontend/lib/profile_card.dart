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
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('name'),
              Text(name!),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('email'),
              Text(email!),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Age: $age'),
            ],
          ),
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.cyan,
            child: avatarUrl != null
                ? ClipOval(
              child: Image.network(
                avatarUrl!,
                width: 120,  // 2 * radius
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              ),
            )
                : Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
    // TODO: Implement profile card UI
    return Container(
      width: 600,
      height: 500,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurple[100],
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.deepPurple,
            blurRadius: 15,
            offset: Offset(0, 10),
          )
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CircleAvatar(
            radius: 60,
            child: avatarUrl == null ?
            const Text('Photo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),)
                : Image.network('$avatarUrl')
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                margin: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple[300]!,
                      Colors.deepPurple[500]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Text('${this.name}', style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  fontFamily: 'TimesNew Roman',
                ),),
              )
            ],
          ),
          Container(
            width: 600,
            padding: const EdgeInsets.all(20),
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide.none,
                              right: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              left: BorderSide.none,
                            ),
                          ),
                          child: const Text('Email:', style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'Times New Roman',
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                        Container(
                          width: 100,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide.none,
                              right: BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                              bottom: BorderSide.none,
                              left: BorderSide.none,
                            ),
                          ),
                          child: const Text('Age:', style: TextStyle(
                            fontSize: 24,
                            fontFamily: 'TimesNew Roman',
                            fontWeight: FontWeight.bold,
                          ),),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 300,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              border: Border(
                                top: BorderSide.none,
                                right: BorderSide.none,
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 1.0,
                                ),
                                left: BorderSide.none,
                              ),
                            ),
                            child: Text('${this.email}', style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'TimesNew Roman',
                              fontWeight: FontWeight.normal,
                            ),),
                          ),
                        Container(
                            width: 300,
                            alignment: Alignment.center,
                            child: Text('${this.age}', style: const TextStyle(
                              fontSize: 24,
                              fontFamily: 'TimesNew Roman',
                              fontWeight: FontWeight.normal,
                            ),),
                          ),
                      ],
                    ),
                  ],
                )
          )
        ],
      )
    );
  }
}
