import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';
import 'services/secure_storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализировать все необходимые сервисы
  try {
    // Инициализировать PreferencesService
    await PreferencesService.init();

    // Инициализировать DatabaseService (создаст базу данных, если нужно)
    await DatabaseService.database;

    // Инициализировать SecureStorageService (не требует явной инициализации, но можно проверить доступность)
    // await SecureStorageService.saveSecureData('init_check', 'ok');
  } catch (e) {
    print('Ошибка инициализации сервисов: $e');
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
