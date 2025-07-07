import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/message.dart';
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

    return MultiProvider(
        providers: [
          Provider(create: (_) => ApiService())
        ],
      child: MaterialApp(
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
        home: const ChatScreen(

        ),
        // TODO: Add error handling for navigation
        // TODO: Consider adding splash screen or loading widget
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => const UnknownRouteScreen(),
          );
        },

      )
    );
  }
}

class UnknownRouteScreen extends StatelessWidget {
  const UnknownRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(child: Text('404 - Page Not Found')),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
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
    } catch (e) {
      _error = 'Failed to load messages: $e';
    } finally {
      _isLoading = false;
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
    } catch (e) {
      _error = 'Failed to create message: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add updateMessage(int id, UpdateMessageRequest request) method
  // Call API to update message, update in local list
  Future<void> updateMessage(int id, UpdateMessageRequest request)async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      final updatedMessage = await _apiService.updateMessage(id, request);
      final idx = _messages.indexWhere((msg) => msg.id == id);
      if(idx != -1){
        _messages[idx] = updatedMessage;
      }
    } catch(e){
      _error = "Failed to update message: $e";
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add deleteMessage(int id) method
  // Call API to delete message, remove from local list
  Future<void> deleteMessage(id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      await _apiService.deleteMessage(id);
      _messages.removeWhere((msg) => msg.id == id);
    } catch(e){
      _error = "Failed to remove element: $e";
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add refreshMessages() method
  // Clear current messages and reload from API
  void refreshMessages() async{
    _isLoading = true;
    _error = null;
    notifyListeners();

    try{
      _messages.clear();
      _messages = await _apiService.getMessages();
    } catch(e){
      _error = "Failed to refresh messages: $e";
    } finally{
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: Add clearError() method
  // Set _error = null and call notifyListeners()
  void clearError(){
    _error = null;
    notifyListeners();
  }
}
