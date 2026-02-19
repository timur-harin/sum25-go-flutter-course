import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';
import 'services/secure_storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  try {
    // Initialize PreferencesService
    await PreferencesService.init();

    // Initialize DatabaseService (this will create the database if it doesn't exist)
    await DatabaseService.database;

    // Test SecureStorageService initialization
    await SecureStorageService.saveSecureData('app_initialized', 'true');
    
    print('All services initialized successfully');
  } catch (e) {
    print('Error initializing services: $e');
    // Continue app execution even if some services fail
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
