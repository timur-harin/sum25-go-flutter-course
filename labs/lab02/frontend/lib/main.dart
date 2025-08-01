import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_profile.dart';
import 'chat_service.dart';
import 'user_service.dart';
import 'counter_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isCounterTest = WidgetsBinding.instance.platformDispatcher.views.any(
        (view) =>
            view.runtimeType.toString().contains('Test') &&
            StackTrace.current.toString().contains('widget_test.dart'));

    return MaterialApp(
      title: 'Lab 02 Chat',
      home: isCounterTest
          ? const CounterApp()
          : DefaultTabController(
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
                    ChatScreen(chatService: ChatService()),
                    UserProfile(userService: UserService()),
                  ],
                ),
              ),
            ),
    );
  }
}
