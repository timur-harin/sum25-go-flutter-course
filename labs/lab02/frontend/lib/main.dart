import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'user_service.dart';
import 'chat_screen.dart';
import 'user_profile.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final ChatService chatService = ChatService();
  final UserService userService = UserService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 02 Chat',
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lab 02 Chat'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Chat', icon: Icon(Icons.chat)),
                Tab(text: 'Profile', icon: Icon(Icons.person)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              ChatScreen(chatService: chatService),
              UserProfile(userService: userService),
            ],
          ),
        ),
      ),
    );
  }
}
