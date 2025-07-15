import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hello',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Hello'),
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Hello, World from Go & Flutter summer elective course!',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
