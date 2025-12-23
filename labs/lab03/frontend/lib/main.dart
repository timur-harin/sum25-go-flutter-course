import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Lab03 Chat'),
            bottom: const TabBar(
              tabs: [Tab(text: 'Chat'), Tab(text: 'Status')],
            ),
          ),
          body: const TabBarView(
            children: [ChatScreen()],
          ),
        ),
      ),
    );
  }
}
