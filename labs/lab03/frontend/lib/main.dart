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
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue).copyWith(secondary: Colors.orange),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}