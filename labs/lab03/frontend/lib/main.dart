import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    Provider<ApiService>(
      create: (_) => ApiService(),
      dispose: (_, s) => s.dispose(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Lab 03 REST API Chat',
    theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
    home: const ChatScreen(),
  );
}
