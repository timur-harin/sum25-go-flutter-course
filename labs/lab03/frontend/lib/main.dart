import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/message.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();
    return MultiProvider(
      providers: [
        Provider<ChatProvider>(
            create: (_) => ChatProvider(apiService),
            dispose: (_, apiService) => apiService.dispose())
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primaryColor: Colors.purple,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purpleAccent),
          appBarTheme: const AppBarTheme(color: Colors.blue),
          elevatedButtonTheme: const ElevatedButtonThemeData(
              style: ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Colors.purpleAccent))),
          primarySwatch: Colors.purple,
          useMaterial3: true,
        ),
        home: const ChatScreen(),
      ),
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

  void loadMessages() async {
    try {
      _isLoading = true;
      _messages = await _apiService.getMessages();
      _isLoading = false;
    } on Object catch (e) {
      if (kDebugMode) print('$e');
    }
  }

  void createMessage(CreateMessageRequest request) async {
    try {
      _isLoading = true;
      Message newMessage = await _apiService.createMessage(request);
      _isLoading = false;
      messages.add(newMessage);
      refreshMessages();
    } on Object catch (e) {
      if (kDebugMode) print('$e');
    }
  }

  void updateMessage(int id, UpdateMessageRequest request) async {
    try {
      _isLoading = true;
      Message updatedMessage = await _apiService.updateMessage(id, request);
      _isLoading = false;
      int index = _messages.indexWhere((msg) => msg.id == id);
      _messages[index] = updatedMessage;
      refreshMessages();
    } on Object catch (e) {
      if (kDebugMode) print('$e');
    }
  }

  void deleteMessage(int id) async {
    try {
      _isLoading = true;
      await _apiService.deleteMessage(id);
      _isLoading = false;
      int index = _messages.indexWhere((msg) => msg.id == id);
      messages.removeAt(index);
      refreshMessages();
    } on Object catch (e) {
      if (kDebugMode) print('$e');
    }
  }

  void refreshMessages() async {
    _messages.clear();
    notifyListeners();

    _messages = await _apiService.getMessages();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
