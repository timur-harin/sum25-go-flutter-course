import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_profile.dart';
import 'chat_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final ChatService chatService = ChatService();
  final dynamic userService = null; // TODO: Replace with actual user service

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 02 Chat',
      initialRoute: '/',
      routes: {
        '/': (context) => ChatScreen(chatService: chatService),
        '/profile': (context) => UserProfile(userService: userService),
      },
    );
  }
}
