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
        // Provide ApiService instance
        Provider(create: (context) => ApiService()),
        
        // Provide ChatProvider that depends on ApiService
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(null),
          update: (context, apiService, chatProvider) => 
              ChatProvider(apiService)..loadMessages(),
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.light(
            primary: Colors.blue,
            secondary: Colors.orange, // For HTTP cat theme
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        home: const ChatScreen(),
        builder: (context, child) {
          // Global error handling for navigation
          return Scaffold(
            body: Builder(
              builder: (context) {
                return child!;
              },
            ),
          );
        },
      ),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiService? _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  // Getters
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load messages from API
  Future<void> loadMessages() async {
    if (_apiService == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final messages = await _apiService!.getMessages();
      _messages = messages;
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create new message
  Future<void> createMessage(CreateMessageRequest request) async {
    if (_apiService == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final message = await _apiService!.createMessage(request);
      _messages.add(message);
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update existing message
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    if (_apiService == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      final updatedMessage = await _apiService!.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
      }
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete message
  Future<void> deleteMessage(int id) async {
    if (_apiService == null) return;
    
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService!.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
    } on ApiException catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    _messages = [];
    await loadMessages();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}