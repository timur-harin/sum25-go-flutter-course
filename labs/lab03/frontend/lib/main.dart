import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'models/message.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Wrap MaterialApp with MultiProvider or Provider
    // Provide ApiService instance to the widget tree
    // This allows any widget to access the API service
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ChatProvider(ApiService())),
      ],
      child:  MaterialApp(
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

 Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _apiService.getMessages();
    }
    catch (e) {
      _error = e.toString();
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> createMessage(CreateMessageRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _apiService.createMessage(request);
      _messages.add(message);
    }
    catch (e) {
      _error = e.toString();
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((msg) => msg.id == id);
      if(index != -1) {
        _messages[index] = updatedMessage;
      }
    }
    catch (e) {
      _error = e.toString();
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> deleteMessage(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((msg) => msg.id == id);
    }
    catch (e) {
      _error = e.toString();
    }
    finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshMessages() async {
    _messages.clear();
    await loadMessages();
    notifyListeners();
  }

  Future<void> clearError() async {
    _error = null;
    notifyListeners();
  }
}
