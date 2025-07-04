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
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, apiService) => apiService.dispose(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(
            Provider.of<ApiService>(context, listen: false),
          )..loadMessages(),
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
          useMaterial3: true,
        ),
        home: Consumer<ChatProvider>(
          builder: (context, chatProvider, _) {
            if (chatProvider.isLoading && chatProvider.messages.isEmpty) {
              return const SplashScreen();
            }
            return const ChatScreen();
          },
        ),
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Page Not Found')),
              body: const Center(child: Text('404 - Page Not Found')),
            ),
          );
        },
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading chat...'),
          ],
        ),
      )
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
    } catch(e) {
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
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      notifyListeners();
    } catch(e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
    } catch(e) {
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
    } catch(e) {
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
