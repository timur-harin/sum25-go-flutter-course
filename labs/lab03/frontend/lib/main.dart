import 'package:flutter/material.dart';
import 'package:lab03_frontend/models/message.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => ApiService()),
        ChangeNotifierProvider(
          create: (ctx) => ChatProvider(ctx.read<ApiService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme:
              ColorScheme.fromSwatch().copyWith(secondary: Colors.orange),
          useMaterial3: true,
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

  // TODO: Add constructor that takes ApiService
  // ChatProvider(this._apiService);
  ChatProvider(this._apiService);

  // TODO: Add getters for all private fields
  // List<Message> get messages => _messages;
  List<Message> get messages => _messages;
  // bool get isLoading => _isLoading;
  bool get IsLoading => _isLoading;
  // String? get error => _error;
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
  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      final msg = await _apiService.createMessage(request);
      _messages.add(msg);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updated = await _apiService.updateMessage(id, request);
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
    await loadMessages();
  }

  // TODO: Add clearError() method
  // Set _error = null and call notifyListeners()
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
