import 'package:flutter/material.dart';
import 'package:frontend/counter_app.dart';
import 'package:frontend/profile_card.dart';
import 'package:frontend/registration_form.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Lab 01 Demo: First Flutter Application'),
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
                  name: 'ILIMAMO ALI BILASSAD BASHAR',
                  email: 'BASHAR@example.com',
                  age: 30,
                  avatarUrl:
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSHOFPH9idp0f95w1fD2hy_EO3QlU2p9poJpQ&s', // Replace with actual URL or null
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
