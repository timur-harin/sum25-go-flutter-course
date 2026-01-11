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
    return MultiProvider(
      providers: [
        Provider(create: (context) => ApiService()),
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(null),
          update: (context, apiService, chatProvider) => 
              ChatProvider(apiService).._apiService = apiService,
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.orange,
          ),
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        builder: (context, child) {
          // Global error handling
          final error = Provider.of<ChatProvider>(context).error;
          if (error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }
          return child!;
        },
      ),
    );
  }
}

class ChatProvider extends ChangeNotifier {
  ApiService? _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMessages() async {
    if (_apiService == null) return;
    
    _setLoading(true);
    try {
      final messages = await _apiService!.getMessages();
      _messages = messages;
      _error = null;
    } catch (e) {
      _error = 'Failed to load messages: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createMessage(CreateMessageRequest request) async {
    if (_apiService == null) return;
    
    _setLoading(true);
    try {
      final newMessage = await _apiService!.createMessage(request);
      _messages.add(newMessage);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to send message: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    if (_apiService == null) return;
    
    _setLoading(true);
    try {
      final updatedMessage = await _apiService!.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to update message: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteMessage(int id) async {
    if (_apiService == null) return;
    
    _setLoading(true);
    try {
      await _apiService!.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete message: ${e.toString()}';
    } finally {
      _setLoading(false);
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

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}