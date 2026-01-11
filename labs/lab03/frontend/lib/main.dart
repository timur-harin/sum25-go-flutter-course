import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'models/message.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // TODO: Wrap MaterialApp with MultiProvider or Provider
//     // Provide ApiService instance to the widget tree
//     // This allows any widget to access the API service
//     return MaterialApp(
//       title: 'Lab 03 REST API Chat',
//       theme: ThemeData(
//         // TODO: Customize theme colors
//         // Set primary color to blue
//         // Set accent color to orange (for HTTP cat theme)
//         // Configure app bar theme
//         // Configure elevated button theme
//         primarySwatch: Colors.blue,
//         useMaterial3: true,
//       ),
//       home: const ChatScreen(),
//       // TODO: Add error handling for navigation
//       // TODO: Consider adding splash screen or loading widget
//     );
//   }
// }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp with MultiProvider to provide ApiService and ChatProvider
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
          dispose: (_, apiService) => apiService.dispose(),
        ),
        ChangeNotifierProvider<ChatProvider>(
          create: (context) => ChatProvider(context.read<ApiService>()),
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.blue,
            accentColor: Colors.orange, // For HTTP cat theme
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        // You can add error handling for navigation or a splash screen here if needed
      ),
    );
  }
}

// TODO: Create Provider class for managing app state
// class ChatProvider extends ChangeNotifier {
//   // TODO: Add final ApiService _apiService;
//   // TODO: Add List<Message> _messages = [];
//   // TODO: Add bool _isLoading = false;
//   // TODO: Add String? _error;

//   // TODO: Add constructor that takes ApiService
//   // ChatProvider(this._apiService);

//   // TODO: Add getters for all private fields
//   // List<Message> get messages => _messages;
//   // bool get isLoading => _isLoading;
//   // String? get error => _error;

//   // TODO: Add loadMessages() method
//   // Set loading state, call API, update messages, handle errors

//   // TODO: Add createMessage(CreateMessageRequest request) method
//   // Call API to create message, add to local list

//   // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
//   // Call API to update message, update in local list

//   // TODO: Add deleteMessage(int id) method
//   // Call API to delete message, remove from local list

//   // TODO: Add refreshMessages() method
//   // Clear current messages and reload from API

//   // TODO: Add clearError() method
//   // Set _error = null and call notifyListeners()
// }

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
      final msgs = await _apiService.getMessages();
      _messages = msgs;
    } catch (e) {
      throw UnimplementedError();
    } finally {
      throw UnimplementedError();
    }
  }

  Future<void> createMessage(CreateMessageRequest request) async {
    try {
      final newMsg = await _apiService.createMessage(request);
      _messages.add(newMsg);
      _error = null;
      notifyListeners();
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updated = await _apiService.updateMessage(id, request);
      final idx = _messages.indexWhere((m) => m.id == id);
      if (idx != -1) _messages[idx] = updated;
      _error = null;
      notifyListeners();
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<void> deleteMessage(int id) async {
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      throw UnimplementedError();
    }
  }

  Future<void> refreshMessages() async {
    _messages.clear();
    notifyListeners();
    await loadMessages();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
