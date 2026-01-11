import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'models/message.dart';

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
      dispose: (_, s) => s.dispose(),
    ),
    ChangeNotifierProxyProvider<ApiService, ChatProvider>(
      create: (context) =>
          ChatProvider(Provider.of<ApiService>(context, listen: false)),
      update: (context, apiService, previous) =>
          previous ?? ChatProvider(apiService),
    ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        // Simplified error handling
        onGenerateRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const ChatScreen(),
          );
        },
      ),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(ApiService apiService) : _apiService = apiService;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages() async {
    _setLoading(true);
    try {
      final messages = await _apiService.getMessages();
      _messages = messages;
      _error = null;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createMessage(CreateMessageRequest request) async {
    _setLoading(true);
    try {
      final newMessage = await _apiService.createMessage(request);
      _messages = [newMessage, ..._messages];
      _error = null;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    _setLoading(true);
    try {
      final updated = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updated;
      }
      _error = null;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMessage(int id) async {
    _setLoading(true);
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      _error = null;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshMessages() async {
    _messages = [];
    notifyListeners();
    await loadMessages();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
