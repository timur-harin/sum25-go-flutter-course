import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lab03_frontend/models/message.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
// import 'providers/chat_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()), // Provide ApiService to the widget tree
        ChangeNotifierProvider(create: (context) => ChatProvider(context.read<ApiService>())), // Provide ChatProvider
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue, // Set primary color to blue
          // accentColor: Colors.orange, // Set accent color to orange for HTTP cat theme
          appBarTheme: const AppBarTheme(color: Colors.blue), // Configure app bar theme
          elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(iconColor:  Colors.orange)), // Configure elevated button theme
        ),
        home: const ChatScreen(),
        // Error handling for navigation can be added here
        // A splash screen or loading widget can be added as the first screen
      ),
    );
  }
}

// Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService; // ApiService to interact with the backend
  List<Message> _messages = []; // List to store messages
  bool _isLoading = false; // Loading state
  String? _error; // Error message

  // Constructor
  ChatProvider(this._apiService);

  // Getters for all private fields
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load messages from API
  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new message
  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to create message: $e';
      notifyListeners();
    }
  }

  // Update an existing message
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update message: $e';
      notifyListeners();
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((msg) => msg.id == id);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete message: $e';
      notifyListeners();
    }
  }

  // Refresh messages
  Future<void> refreshMessages() async {
    _messages.clear();
    await loadMessages();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
