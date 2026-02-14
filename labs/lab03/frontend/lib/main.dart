import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'models/message.dart';

void main() {
  // Установка глобального обработчика ошибок
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('An error occurred: ${details.exception}'),
      ),
    );
  };
  
  runApp(const MyApp());
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final dynamic error;
  
  const ErrorScreen({Key? key, required this.error}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text('Error occurred: ${error.toString()}'),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (context) => ApiService()),
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) => ChatProvider(null),
          update: (context, apiService, chatProvider) => 
              chatProvider!..apiService = apiService,
        ),
      ],
      child: FutureBuilder(
        future: _initializeApp(),
        builder: (context, snapshot) {
          Widget home;
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              home = ErrorScreen(error: snapshot.error);
            } else {
              home = const ChatScreen();
            }
          } else {
            home = const SplashScreen();
          }

          return MaterialApp(
            title: 'Lab 03 REST API Chat',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: home,
          );
        },
      ),
    );
  }
}

// State management class
class ChatProvider extends ChangeNotifier {
  ApiService? _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  // Getters for all private fields
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  set apiService(ApiService apiService) {
    _apiService = apiService;
  }

  // Loads messages from API and updates state with errors handling
  Future<void> loadMessages() async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      if (_apiService != null) {
        _messages = await _apiService!.getMessages();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Create a new message via API
  Future<void> createMessage(CreateMessageRequest request) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      if (_apiService != null) {
        final newMessage = await _apiService!.createMessage(request);
        _messages.add(newMessage);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Updates an existing message via API
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      if (_apiService != null) {
        final updatedMessage = await _apiService!.updateMessage(id, request);
        final index = _messages.indexWhere((m) => m.id == id);
        if (index != -1) {
          _messages[index] = updatedMessage;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Deletes a message via API
  Future<void> deleteMessage(int id) async {
    _setLoading(true);
    _error = null;
    notifyListeners();

    try {
      if (_apiService != null) {
        await _apiService!.deleteMessage(id);
        _messages.removeWhere((m) => m.id == id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Refreshes messages by clearing current messages
  Future<void> refreshMessages() async {
    _messages = [];
    await loadMessages();
  }

  // Clears the current error state
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Method to update loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}