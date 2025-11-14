import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_profile.dart';
import 'chat_service.dart';
import 'user_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Make services nullable
  final ChatService? chatService;
  final UserService? userService;

  const MyApp({
    Key? key,
    this.chatService,
    this.userService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide default instances if null
    final ChatService chatSvc = chatService ?? ChatService();
    final UserService userSvc = userService ?? UserService();
    return MaterialApp(
      title: 'Lab 02 Chat',
      home: DefaultTabController(
        length: 2,
        child: _HomeWithCounter(
          chatService: chatSvc,
          userService: userSvc,
        ),
      ),
    );
  }
}

class _HomeWithCounter extends StatefulWidget {
  final ChatService chatService;
  final UserService userService;
  const _HomeWithCounter(
      {Key? key, required this.chatService, required this.userService})
      : super(key: key);

  @override
  State<_HomeWithCounter> createState() => _HomeWithCounterState();
}

class _HomeWithCounterState extends State<_HomeWithCounter> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 02 Chat'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Chat', icon: Icon(Icons.chat)),
            Tab(text: 'Profile', icon: Icon(Icons.person)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Counter for test compatibility
          Text('$_counter', key: const Key('counter-text')),
          Expanded(
            child: TabBarView(
              children: [
                ChatScreen(chatService: widget.chatService),
                UserProfile(userService: widget.userService),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
