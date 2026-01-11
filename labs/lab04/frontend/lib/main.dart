import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart'; // Import your database service if needed
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter engine and bindings are initialized before any async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services before running the app
  try {
    // Initialize SharedPreferences service
    await PreferencesService.init();

    // Initialize Database service (uncomment if needed)
    // await DatabaseService.database;

    // Initialize other services here if necessary
    // await SecureStorageService.init();
  } catch (e) {
    // Print error if initialization fails
    print('Error initializing services: $e');
  }

  // Run the main app widget
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
