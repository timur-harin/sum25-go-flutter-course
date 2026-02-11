import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_profile.dart';
import 'chat_service.dart';
import 'user_service.dart';

void main() {
  // Initializing the app
  final chatService = ChatService();
  final userService = UserService();

  // Running the app
  runApp(MyApp(
    chatService: chatService,
    userService: userService,
  ));
}

class MyApp extends StatelessWidget {
  final ChatService chatService;
  final UserService userService;

  const MyApp({
    Key? key,
    required this.chatService,
    required this.userService,
  }) : super(key: key);

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

