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
    return MaterialApp(
      title: 'Lab 03 REST API Chat',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

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
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }

  Future<void> createMessage(String username, String content) async {
    final request = CreateMessageRequest(
      username: username,
      content: content,
    );
    final validation = request.validate();
    if (validation != null) throw ApiException(validation);
    final msg = await _apiService.createMessage(request);
    _messages.add(msg);
    notifyListeners();
  }

  Future<void> updateMessage(int id, String content) async {
    final request = UpdateMessageRequest(content: content);
    final validation = request.validate();
    if (validation != null) throw ApiException(validation);
    final updated = await _apiService.updateMessage(id, request);
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = updated;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(int id) async {
    await _apiService.deleteMessage(id);
    _messages.removeWhere((m) => m.id == id);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}