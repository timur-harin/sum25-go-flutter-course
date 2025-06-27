import 'package:flutter/material.dart';
import 'counter_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Lab 01 Demo'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Profile'),
              Tab(text: 'Counter'),
              Tab(text: 'Register'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                // TODO: change to ProfileCard
                child: SizedBox.shrink(),
              ),
            ),
            CounterApp(),
            RegistrationForm(),
          ],
        ),
      ),
    );
  }
}
