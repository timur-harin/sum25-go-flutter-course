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
    return Provider<ApiService>(
      create: (_) => ApiService(),
      dispose: (_, api) => api.dispose(),
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          // TODO: Customize theme colors
          // Set primary color to blue
          // Set accent color to orange (for HTTP cat theme)
          // Configure app bar theme
          // Configure elevated button theme
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.orange),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        // TODO: Add error handling for navigation
        // TODO: Consider adding splash screen or loading widget
      ),
    );
  }
}

// TODO: Create Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  // TODO: Add final ApiService _apiService;
  // TODO: Add List<Message> _messages = [];
  // TODO: Add bool _isLoading = false;
  // TODO: Add String? _error;
  final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  // TODO: Add constructor that takes ApiService
  // ChatProvider(this._apiService);
  ChatProvider(this._apiService);

  // TODO: Add getters for all private fields
  // List<Message> get messages => _messages;
  // bool get isLoading => _isLoading;
  // String? get error => _error;
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // TODO: Add loadMessages() method
  // Set loading state, call API, update messages, handle errors
  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add createMessage(CreateMessageRequest request) method
  // Call API to create message, add to local list
  Future<void> createMessage(String username, String content) async {
    try {
      // final newMessage = await _apiService.createMessage(username, content);
      final newMessage = await _apiService.createMessage(CreateMessageRequest(username: username, content: content));
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list
  Future<void> updateMessage(int id, String content) async {
    try {
      // final updated = await _apiService.updateMessage(id, content);
      final updated = await _apiService.updateMessage(id, UpdateMessageRequest(content: content));
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list
  Future<void> deleteMessage(int id) async {
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // TODO: Add refreshMessages() method
  // Clear current messages and reload from API
  Future<void> refreshMessages() async {
  _messages = [];
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    _messages = await _apiService.getMessages();
  } catch (e) {
    _error = e.toString();
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // TODO: Add clearError() method
  // Set _error = null and call notifyListeners()
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
