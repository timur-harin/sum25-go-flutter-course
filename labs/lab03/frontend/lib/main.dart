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
    return Provider<ApiService>(
      create: (_) => ApiService(),
      dispose: (_, apiService) => apiService.dispose(),
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            primary: Colors.blue,
            secondary: Colors.orange,
            brightness: Brightness.light,
          ),
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}

// TODO: Create Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  ChatProvider(this._apiService);
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final messages = await _apiService.getMessages();
      _messages = messages;
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
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final newMessage = await _apiService.createMessage(request);
      _messages.insert(0, newMessage);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updated;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list
  Future<void> deleteMessage(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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