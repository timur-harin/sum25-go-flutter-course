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
    final ApiService _apiService = ApiService();
    return MultiProvider(
        providers: [
          Provider<ApiService>.value(value: _apiService),
          ChangeNotifierProvider(create: (_) => ChatProvider(_apiService)),
        ],
        child: MaterialApp(
          title: 'Lab 03 REST API Chat',
          theme: ThemeData(
            primaryColor: Colors.blue,
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              accentColor: Colors.orange,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            primarySwatch: Colors.blue,
            useMaterial3: true,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          initialRoute: '/',
          routes: {
            '/splash': (context) => const CircularProgressIndicator(),
            '/': (context) => const ChatScreen(),
          },
          onUnknownRoute: (settings) => MaterialPageRoute(
            builder: (colonization) => const Scaffold(
              body: Center(
                child: Text('404: Page not found'),
              ),
            ),
          ),
        ));
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
    try {
      _isLoading = true;
      notifyListeners();
      _messages = await _apiService.getMessages();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      _isLoading = true;
      notifyListeners();
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((msg) => msg.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      _isLoading = true;
      notifyListeners();
      await _apiService.deleteMessage(id);
      _messages.removeWhere((msg) => msg.id == id);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMessages() async {
    try {
      _isLoading = true;
      _messages = [];
      notifyListeners();
      _messages = await _apiService.getMessages();
      _error = null;
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
