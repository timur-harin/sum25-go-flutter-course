import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';
import 'services/secure_storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация сервисов
  try {
    // Инициализация SharedPreferences
    await PreferencesService.init();
    
    // Инициализация базы данных SQLite
    await DatabaseService.database;
    
    // Инициализация Secure Storage (не требует явной инициализации)
    // Проверка работы Secure Storage
    const storage = FlutterSecureStorage();
    await storage.write(key: 'init_test', value: 'test');
    await storage.delete(key: 'init_test');

    print('All services initialized successfully');
  } catch (e) {
    print('Error initializing services: $e');
    // Можно добавить обработку критических ошибок инициализации
    // Например, показать экран ошибки или использовать fallback-решения
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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 4,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}