// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<ApiService>(
      create: (_) => ApiService(),
      dispose: (_, apiService) => apiService.dispose(),
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.orange,
            brightness: Brightness.dark,
            cardColor: Colors.grey[800],
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[900],
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.orange,
            ),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
    );
  }
}