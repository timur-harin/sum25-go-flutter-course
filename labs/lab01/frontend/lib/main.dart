import 'package:flutter/material.dart';
import 'package:frontend/profile_card.dart';
import 'package:frontend/counter_app.dart';
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
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab 01 Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              // Profile Card Example
              Text(
                'Profile Card Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              ProfileCard(
                name: 'John Doe',
                email: 'john@example.com',
                age: 30,
                avatarUrl: null, // или URL, если нужен аватар
              ),
              SizedBox(height: 24),
              // Counter Example
              Text(
                'Counter Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              CounterApp(),
              SizedBox(height: 24),
              // Registration Form Example
              Text(
                'Registration Form Example',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              RegistrationForm(),
              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
