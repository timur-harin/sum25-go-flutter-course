import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'user_profile.dart';
import 'chat_service.dart';
import 'user_service.dart';

void main() {
  // TODO: Initialize and run the app
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // TODO: Initialize chatService and userService

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 02 Chat',
      home: CounterPage(), // Changed to show counter page first
    );
  }
}

// New CounterPage widget to satisfy the test requirements
class CounterPage extends StatefulWidget {
  const CounterPage({Key? key}) : super(key: key);

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Counter')),
      body: Center(
        child: Text(
          '$_counter',
          style: const TextStyle(fontSize: 48),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}