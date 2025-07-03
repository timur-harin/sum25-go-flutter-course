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
    // TODO: Wrap MaterialApp with MultiProvider or Provider
    // Provide ApiService instance to the widget tree
    // This allows any widget to access the API service
    return MaterialApp(
      title: 'Lab 03 REST API Chat',
      theme: ThemeData(
        // TODO: Customize theme colors
        // Set primary color to blue
        // Set accent color to orange (for HTTP cat theme)
        // Configure app bar theme
        // Configure elevated button theme
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ChatScreen(),
      // TODO: Add error handling for navigation
      // TODO: Consider adding splash screen or loading widget
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
}
