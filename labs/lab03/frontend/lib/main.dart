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
    // TODO: Wrap MaterialApp with MultiProvider or Provider
    // Provide ApiService instance to the widget tree
    // This allows any widget to access the API service
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, api) => api.dispose(),
        ),
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(
            Provider.of<ApiService>(context, listen: false),
          ),
          update: (context, apiService, previous) =>
          previous ?? ChatProvider(apiService),
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          // TODO: Customize theme colors
          // Set primary color to blue
          // Set accent color to orange (for HTTP cat theme)
          // Configure app bar theme
          // Configure elevated button theme
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        // TODO: Add error handling for navigation
        onGenerateRoute: (settings) => MaterialPageRoute(
          builder: (_) => const ChatScreen(),
        ),
        // TODO: Consider adding splash screen or loading widget
      ),
    );
  }
}

// TODO: Create Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  // TODO: Add final ApiService _apiService;
  final ApiService _apiService;

  // TODO: Add List<Message> _messages = [];
  List<Message> _messages = [];

  // TODO: Add bool _isLoading = false;
  bool _isLoading = false;

  // TODO: Add String? _error;
  String? _error;

  // TODO: Add constructor that takes ApiService
  ChatProvider(this._apiService);

  // TODO: Add getters for all private fields
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Add loadMessages() method
  Future<void> loadMessages() async {
    _setLoading(true);
    try {
      final result = await _apiService.getMessages();
      _messages = result;
      _error = null;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // TODO: Add createMessage(CreateMessageRequest request) method
  Future<void> createMessage(CreateMessageRequest request) async {
    _setLoading(true);
    try {
      final created = await _apiService.createMessage(request);
      _messages = [created, ..._messages];
      _error = null;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
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

  // TODO: Add deleteMessage(int id) method
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

  // TODO: Add refreshMessages() method
  Future<void> refreshMessages() async {
    _messages = [];
    notifyListeners();
    await loadMessages();
  }

  // TODO: Add clearError() method
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}