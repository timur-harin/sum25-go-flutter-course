import 'package:flutter/material.dart';
import 'package:frontend/counter_app.dart';
import 'package:frontend/profile_card.dart';
import 'package:frontend/registration_form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 01 Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

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
                child: ProfileCard(
                  name: 'John Doe',
                  email: 'john@example.com',
                  age: 30,
                  avatarUrl: 'https://example.com/avatar.jpg',
                ),
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

class ProfileCardPage extends StatelessWidget {
  const ProfileCardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Card')),
      body: const Center(
        child: ProfileCard(
          name: 'John Doe',
          email: 'john@example.com',
          age: 30,
          avatarUrl: 'https://example.com/avatar.jpg',
        ),
      ),
    );
  }
}

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const CounterApp();
  }
}

class RegistrationFormPage extends StatelessWidget {
  const RegistrationFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registration Form')),
      body: const Center(child: RegistrationForm()),
    );
  }
}
