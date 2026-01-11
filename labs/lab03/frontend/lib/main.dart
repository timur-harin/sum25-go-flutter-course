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
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(ApiService()),
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          primaryColor: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
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
              elevation: 2,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
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
    _setLoading(true);
    _clearError();

    try {
      _messages = await _apiService.getMessages();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new message
  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Update an existing message
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Refresh messages (clear and reload)
  Future<void> refreshMessages() async {
    _messages.clear();
    await loadMessages();
  }

  // Clear error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get HTTP status information
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    try {
      return await _apiService.getHTTPStatus(statusCode);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Health check
  Future<Map<String, dynamic>> healthCheck() async {
    try {
      return await _apiService.healthCheck();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
