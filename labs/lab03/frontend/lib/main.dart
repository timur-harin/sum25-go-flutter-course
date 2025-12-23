import 'package:flutter/material.dart';
import 'package:lab03_frontend/services/api_service.dart';
import 'package:provider/provider.dart';

import 'models/message.dart';
import 'screens/chat_screen.dart';

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
          ChangeNotifierProxyProvider<ApiService, ChatProvider>(
            create: (context) => ChatProvider(
              Provider.of<ApiService>(context, listen: false),
            ),
            update: (context, apiService, previous) =>
            previous ?? ChatProvider(apiService),
          ),
        ],
        child: MaterialApp(
          title: 'Lab 03 REST API Chat',
          theme: ThemeData(
            primaryColor: Colors.blue,
            colorScheme:
                ColorScheme.fromSwatch().copyWith(secondary: Colors.orange),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.blue,
              titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            ),

            // TODO: Customize theme colors
            // Set primary color to blue
            // Set accent color to orange (for HTTP cat theme)
            // Configure app bar theme
            // Configure elevated button theme
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange, // Text color
              ),
            ),
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const ChatScreen(),
          //error handling for navigation
        ));
  }
}

// TODO: Create Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _messages = await _apiService.getMessages();
    } catch (error) {
      _error = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set loading state, call API, update messages, handle errors

  createMessage(CreateMessageRequest request) async {
    try {
      final message = await _apiService.createMessage(request);
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Call API to create message, add to local list

  updateMessage(int id, UpdateMessageRequest request) async {
    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index =
      _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] =
            updatedMessage; // Update the message in the list
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Call API to update message, update in local list

  deleteMessage(int id) async {
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Call API to delete message, remove from local list

  refreshMessages() async {
    _messages.clear();
    await loadMessages();
    notifyListeners();
  }

  // Clear current messages and reload from API
  void clearError() {
    _error = null;
    notifyListeners();
  }




// Set _error = null and call notifyListeners()
}
