import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'models/message.dart';

void main() {
  print('🔧 main: Starting Flutter app');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('🔧 MyApp: Building app with Provider setup');
    // Wrap MaterialApp with MultiProvider to provide dependencies
    return MultiProvider(
      providers: [
        // Provide ApiService instance to the widget tree
        Provider<ApiService>(
          create: (_) {
            print('🔧 MyApp: Creating ApiService provider');
            return ApiService();
          },
          dispose: (_, apiService) {
            print('🔧 MyApp: Disposing ApiService provider');
            apiService.dispose();
          },
        ),
        // Provide ChatProvider for state management
        ChangeNotifierProxyProvider<ApiService, ChatProvider>(
          create: (context) {
            print('🔧 MyApp: Creating ChatProvider');
            return ChatProvider(
              Provider.of<ApiService>(context, listen: false),
            );
          },
          update: (context, apiService, previous) {
            print('🔧 MyApp: Updating ChatProvider');
            return previous ?? ChatProvider(apiService);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Lab 03 REST API Chat',
        theme: ThemeData(
          // Customize theme colors
          primarySwatch: Colors.blue,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            secondary: Colors.orange, // HTTP cat theme color
          ),
          useMaterial3: true,

          // Configure app bar theme
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 2,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),

          // Configure elevated button theme
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),

          // Configure card theme
          cardTheme: const CardThemeData(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
        ),
        home: const ChatScreen(),

        // Add error handling for navigation
        builder: (context, child) {
          return child ??
              const Scaffold(
                body: Center(
                  child: Text('Navigation Error'),
                ),
              );
        },
      ),
    );
  }
}

// Provider class for managing app state
class ChatProvider extends ChangeNotifier {
  final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  ChatProvider(this._apiService);

  // Getters for all private fields
  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load messages from API
  Future<void> loadMessages() async {
    print('🔧 ChatProvider: Starting to load messages');
    _setLoading(true);
    _clearError();

    try {
      print('🔧 ChatProvider: Calling _apiService.getMessages()');
      _messages = await _apiService.getMessages();
      print(
          '🔧 ChatProvider: Successfully loaded ${_messages.length} messages');
      notifyListeners();
    } catch (e) {
      print('🔧 ChatProvider: Error loading messages: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Create a new message
  Future<void> createMessage(CreateMessageRequest request) async {
    _clearError();

    try {
      final newMessage = await _apiService.createMessage(request);
      _messages.add(newMessage);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-throw to let UI handle the error
    }
  }

  // Update an existing message
  Future<void> updateMessage(int id, UpdateMessageRequest request) async {
    _clearError();

    try {
      final updatedMessage = await _apiService.updateMessage(id, request);
      final index = _messages.indexWhere((m) => m.id == id);
      if (index != -1) {
        _messages[index] = updatedMessage;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-throw to let UI handle the error
    }
  }

  // Delete a message
  Future<void> deleteMessage(int id) async {
    _clearError();

    try {
      await _apiService.deleteMessage(id);
      _messages.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-throw to let UI handle the error
    }
  }

  // Refresh messages by reloading from API
  Future<void> refreshMessages() async {
    _messages.clear();
    await loadMessages();
  }

  // Clear current error
  void clearError() {
    _clearError();
  }

  // Get HTTP status from API
  Future<HTTPStatusResponse> getHTTPStatus(int statusCode) async {
    _clearError();

    try {
      return await _apiService.getHTTPStatus(statusCode);
    } catch (e) {
      _setError(e.toString());
      rethrow; // Re-throw to let UI handle the error
    }
  }

  // Private helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }
}
