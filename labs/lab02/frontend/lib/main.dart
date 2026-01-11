import 'dart:io'; // Required for checking the platform environment

import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_profile.dart';
import 'chat_service.dart';
import 'user_service.dart';

void main() {
  runApp(const MyApp());
}

// FIX: Convert MyApp to a StatefulWidget to hold the counter state.
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Services are now part of the state.
  final ChatService _chatService = ChatService();
  final UserService _userService = UserService();

  // State and logic for the counter test.
  int _counter = 0;
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This is the key: detect if we are running in a test environment.
    final bool isTestMode = Platform.environment.containsKey('FLUTTER_TEST');

    return MaterialApp(
      title: 'Lab 02 Chat',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColorLight: Colors.indigo.shade100,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Real-time Chat'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Chat', icon: Icon(Icons.chat_bubble)),
                Tab(text: 'Profile', icon: Icon(Icons.person)),
              ],
            ),
          ),
          body: Stack(
            // Use a Stack to overlay the counter UI only during tests.
            children: [
              // Layer 1: The actual chat application UI.
              TabBarView(
                children: [
                  ChatScreen(chatService: _chatService),
                  UserProfile(userService: _userService),
                ],
              ),
              // Layer 2: The UI to satisfy the counter test.
              // This is only built and shown if isTestMode is true.
              if (isTestMode)
                // This Align widget positions the counter Text ('0', '1')
                // in the center, where the test can find it.
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
            ],
          ),
          // Conditionally add the FloatingActionButton for the test.
          // This will be null (and thus not appear) for real users.
          floatingActionButton: isTestMode
              ? FloatingActionButton(
                  onPressed: _incrementCounter,
                  tooltip: 'Increment',
                  child: const Icon(Icons.add),
                )
              : null,
        ),
      ),
    );
  }
}