import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/message.dart';
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
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, api) => api.dispose(),
        ),

        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(context.read<ApiService>()),
          update: (context, api, previous) =>
          previous!..updateApi(api),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange,
          ),
        ),
        home: const ChatScreen(),
      ),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  ApiService _apiService;

  ChatProvider(this._apiService);

  void updateApi(ApiService newApi) {
    _apiService = newApi;
  }

  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

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
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      final message = await _apiService.createMessage(request);
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

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

  Future<void> refreshMessages() async {
    _messages = [];
    notifyListeners();
    await loadMessages();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
