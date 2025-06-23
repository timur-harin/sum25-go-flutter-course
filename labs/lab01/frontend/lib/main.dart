import 'package:flutter/material.dart';
import 'counter_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Counter'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CounterApp()),
            );
          },
        ),
      ),
    );
  }
}
