import 'package:lab03_frontend/models/message.dart';
import 'package:flutter/material.dart';
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
      Provider<ApiService>(create: (_) => ApiService()),
      ChangeNotifierProvider<ChatProvider>(
        create: (context) => ChatProvider(context.read<ApiService>()),
      ),
    ],
    child: MaterialApp(
      title: 'Lab 03 REST API Chat',
      theme: ThemeData(
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    secondary: Colors.orange, // Accent color
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
    centerTitle: true,
    elevation: 4,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.orange,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    ),
  ),
  useMaterial3: true,
),
      home: const ChatScreen(),
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

  // TODO: Add constructor that takes ApiService
  // ChatProvider(this._apiService);

  // TODO: Add getters for all private fields
  // List<Message> get messages => _messages;
  // bool get isLoading => _isLoading;
  // String? get error => _error;

  // TODO: Add loadMessages() method
  // Set loading state, call API, update messages, handle errors

  // TODO: Add createMessage(CreateMessageRequest request) method
  // Call API to create message, add to local list

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list

  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list

  // TODO: Add refreshMessages() method
  // Clear current messages and reload from API

  // TODO: Add clearError() method
  // Set _error = null and call notifyListeners()
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

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
