import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';
import 'services/secure_storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await PreferencesService.init();
    await DatabaseService.database;

    const bool isTestMode = bool.fromEnvironment('TEST_MODE');
    if (isTestMode) {
      SecureStorageService.enableTestMode();
    }
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
