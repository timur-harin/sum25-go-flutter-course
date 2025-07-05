import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import '../models/message.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
    
    
    
   
        
       
       
      // TODO: Add error handling for navigation
      // TODO: Consider adding splash screen or loading widget
  @override
  Widget build(BuildContext context) {
    // TODO: Wrap MaterialApp with MultiProvider or Provider
    return MultiProvider(
      providers: [
        // Provide ApiService instance to the widget tree
        
        Provider<ApiService>(create: (_) => ApiService()),
        ChangeNotifierProvider(create: (context) => ChatProvider(context.read<ApiService>())),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSwatch(
             //  Set primary color to blue
            primarySwatch: Colors.blue,
            // Set accent color to orange (for HTTP cat theme)
            accentColor: Colors.orange,
          ),
           // Configure app bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 4,
          ),
           // Configure elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          useMaterial3: true,
        ),
        home: const ChatScreen(),
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: const Center(child: Text('404: Page not found')),
          ),
        ),
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
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    notifyListeners();
  }
}
  // TODO: Add createMessage(CreateMessageRequest request) method
  // Call API to create message, add to local list
  Future<void> createMessage(CreateMessageRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
  _isLoading = true;
  _error = null;
  notifyListeners();

  try {
    final updatedMessage = await _apiService.updateMessage(id, request);
    final index = _messages.indexWhere((m) => m.id == id);
    if (index != -1) {
      _messages[index] = updatedMessage;
    }
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _isLoading = false;
    _error = e.toString();
    notifyListeners();
  }
}
  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list
  Future<void> deleteMessage(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  // TODO: Add refreshMessages() method
  // Clear current messages and reload from API
  Future<void> refreshMessages() async {
    _isLoading = true;
    _error = null;
    _messages = [];
    notifyListeners();

    try {
      _messages = await _apiService.getMessages();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
  // TODO: Add clearError() method
  // Set _error = null and call notifyListeners()
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
