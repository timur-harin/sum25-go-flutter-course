import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'screens/home_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any async operations
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize required services before running the app
  try {
    // Initialize the preferences service (e.g., SharedPreferences)
    await PreferencesService.init();

    // TODO: Add initialization for other services if needed, e.g., DatabaseService
    // await DatabaseService.init();
  } catch (e) {
    // Print any errors encountered during initialization
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
        // Use a seed color for the color scheme
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        // Enable Material 3 design system
        useMaterial3: true,
      ),
      // Set the home screen of the app
      home: const HomeScreen(),
      // Hide the debug banner
      debugShowCheckedModeBanner: false,
    );
  }
}
