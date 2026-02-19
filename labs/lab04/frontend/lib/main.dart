import 'package:flutter/material.dart';
import 'services/preferences_service.dart';
import 'services/database_service.dart';
import 'services/secure_storage_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Инициализируем все сервисы
    await PreferencesService.init();
    await DatabaseService.database; // Инициализация базы данных
    await SecureStorageService.clearAll(); // Очистка для тестов (опционально)

    // Можно добавить тестовые данные для демонстрации
    await _addTestData();
  } catch (e) {
    print('Error initializing services: $e');
  }

  runApp(const MyApp());
}

Future<void> _addTestData() async {
  await PreferencesService.setString('test_pref', 'Hello Preferences!');
  await SecureStorageService.saveSecureData('test_secure', 'Secure Data');
  await DatabaseService.createUser(
      CreateUserRequest(name: 'Test User', email: 'test@example.com'));
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
