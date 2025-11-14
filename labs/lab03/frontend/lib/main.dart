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
        Provider(create: (context) => ApiService()),
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(null),
          update: (context, apiService, chatProvider) => 
              ChatProvider(apiService)..loadMessages(),
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 4,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        // TODO: Add error handling for navigation
        // TODO: Consider adding splash screen or loading widget
        builder: (context, child) {
          return Scaffold(
            body: child,
          );
        },
      ),
    );
  }
}

// TODO: Create Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  // TODO: Add final ApiService _apiService;
  final ApiService? _apiService;
  
  // TODO: Add List<Message> _messages = [];
  List<Message> _messages = [];
  
  // TODO: Add bool _isLoading = false;
  bool _isLoading = false;
  
  // TODO: Add String? _error;
  String? _error;

  // TODO: Add constructor that takes ApiService
  // ChatProvider(this._apiService);
  ChatProvider(this._apiService);

  // TODO: Add getters for all private fields
  // List<Message> get messages => _messages;
  List<Message> get messages => _messages;
  
  // bool get isLoading => _isLoading;
  bool get isLoading => _isLoading;
  
  // String? get error => _error;
  String? get error => _error;

  // TODO: Add loadMessages() method
  // Set loading state, call API, update messages, handle errors
  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final messages = await _apiService?.getMessages();
      if (messages != null) {
        _messages = messages;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add createMessage(CreateMessageRequest request) method
  // Call API to create message, add to local list
  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      final message = await _apiService?.createMessage(request);
      if (message != null) {
        _messages.add(message);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updatedMessage = await _apiService?.updateMessage(id, request);
      if (updatedMessage != null) {
        final index = _messages.indexWhere((m) => m.id == id);
        if (index != -1) {
          _messages[index] = updatedMessage;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list
  Future<void> deleteMessage(int id) async {
    try {
      await _apiService?.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // TODO: Add refreshMessages() method
  // Clear current messages and reload from API
  Future<void> refreshMessages() async {
    _messages = [];
    await loadMessages();
  }

  // TODO: Add clearError() method
  // Set _error = null and call notifyListeners()
  void clearError() {
    _error = null;
    notifyListeners();
  }
}