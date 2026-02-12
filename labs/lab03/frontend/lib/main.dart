import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'models/message.dart';  // если нужно для типов

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, api) => api.dispose(),
        ),
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(context.read<ApiService>()),
          update: (context, api, previous) => previous!..updateApiService(api),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lab 03 REST API Chat',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  late ApiService _apiService;

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  void updateApiService(ApiService apiService) {
    _apiService = apiService;
  }

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createMessage(CreateMessageRequest request) async {
    _error = null;
    notifyListeners();

    try {
      final message = await _apiService.createMessage(request);
      _messages.insert(0, message);
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    _error = null;
    notifyListeners();

    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
      }
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> deleteMessage(int id) async {
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
    } catch (e) {
      _error = e.toString();
    }

    notifyListeners();
  }

  Future<void> refreshMessages() async {
    _messages.clear();
    notifyListeners();
    await loadMessages();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
