import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize services
  try {
    // TODO: Initialize PreferencesService
    await PreferencesService.init();

    // TODO: Add any other service initialization here
    // For example: await DatabaseService.database;
  } catch (e) {
    print('Error initializing services: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 04 - Database & Persistence',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
