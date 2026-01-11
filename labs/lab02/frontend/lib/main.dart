import 'package:flutter/material.dart';
import 'package:lab02_chat/chat_screen.dart';
import 'package:lab02_chat/chat_service.dart';
import 'package:lab02_chat/user_profile.dart';
import 'package:lab02_chat/user_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final chatService = ChatService();
  final userService = UserService();

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
              ChatScreen(chatService: chatService),    // передаем chatService
              UserProfile(userService: userService),   // передаем userService
            ],
          ),
        ),
      ),
    );
  }
}
