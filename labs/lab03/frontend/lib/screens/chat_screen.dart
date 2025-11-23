import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // TODO: Add final ApiService _apiService = ApiService();
  // TODO: Add List<Message> _messages = [];
  // TODO: Add bool _isLoading = false;
  // TODO: Add String? _error;
  // TODO: Add final TextEditingController _usernameController = TextEditingController();
  // TODO: Add final TextEditingController _messageController = TextEditingController();
  late ApiService _apiService;
  bool _initialized = false;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _apiService = Provider.of<ApiService>(context, listen: false);
      _loadMessages();
      _initialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _loadMessages();
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and API service
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    // TODO: Implement _loadMessages
    // Set _isLoading = true and _error = null
    // Try to get messages from _apiService.getMessages()
    // Update _messages with result
    // Catch any exceptions and set _error
    // Set _isLoading = false in finally block
    // Call setState() to update UI
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final messages = await _apiService.getMessages();
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    // TODO: Implement _sendMessage
    // Get username and content from controllers
    // Validate that both fields are not empty
    // Create CreateMessageRequest
    // Try to send message using _apiService.createMessage()
    // Add new message to _messages list
    // Clear the message controller
    // Catch any exceptions and show error
    // Call setState() to update UI
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    if (username.isEmpty || content.isEmpty) return;

    final request = CreateMessageRequest(username: username, content: content);
    final error = request.validate();
    if (error != null) {
      _showError(error);
      return;
    }

    try {
      final message = await _apiService.createMessage(request);
      setState(() {
        _messages.insert(0, message);
        _messageController.clear();
      });

      // ✅ Показываем SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent')),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _editMessage(Message message) async {
    // TODO: Implement _editMessage
    // Show dialog with text field pre-filled with message content
    // Allow user to edit the content
    // When saved, create UpdateMessageRequest
    // Try to update message using _apiService.updateMessage()
    // Update the message in _messages list
    // Catch any exceptions and show error
    // Call setState() to update UI
    final controller = TextEditingController(text: message.content);

    final updated = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: "Content"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text("Save")),
        ],
      ),
    );

    if (updated != null && updated.trim().isNotEmpty) {
      try {
        final request = UpdateMessageRequest(content: updated);
        final result = await _apiService.updateMessage(message.id, request);
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) _messages[index] = result;
        });
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    // TODO: Implement _deleteMessage
    // Show confirmation dialog
    // If confirmed, try to delete using _apiService.deleteMessage()
    // Remove message from _messages list
    // Catch any exceptions and show error
    // Call setState() to update UI
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Delete message from ${message.username}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
        });
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    // TODO: Implement _showHTTPStatus
    // Try to get HTTP status info using _apiService.getHTTPStatus()
    // Show dialog with status code, description, and HTTP cat image
    // Use Image.network() to display the cat image
    // http.cat
    // Handle loading and error states for the image
    try {
      final result = await _apiService.getHTTPStatus(statusCode);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("HTTP Status: ${result.statusCode}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(result.description),
              const SizedBox(height: 8),
              Image.network(result.imageUrl, errorBuilder: (_, __, ___) => const Icon(Icons.error)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))
          ],
        ),
      );
    } catch (e) {
      _showError("Could not load status image: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
    ));
  }

  Widget _buildMessageTile(Message message) {
    // TODO: Implement _buildMessageTile
    // Return ListTile with:
    // - leading: CircleAvatar with first letter of username
    // - title: Text with username and timestamp
    // - subtitle: Text with message content
    // - trailing: PopupMenuButton with Edit and Delete options
    // - onTap: Show HTTP status dialog for random status code (200, 404, 500)
    // return Container(); // Placeholder
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text("${message.username} — ${message.timestamp.toLocal()}"),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') _editMessage(message);
          if (value == 'delete') _deleteMessage(message);
        },
        itemBuilder: (_) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        _showHTTPStatus(codes[Random().nextInt(codes.length)]);
      },
    );
  }

  Widget _buildMessageInput() {
    // TODO: Implement _buildMessageInput
    // Return Container with:
    // - Padding and background color
    // - Column with username TextField and message TextField
    // - Row with Send button and HTTP Status demo buttons (200, 404, 500)
    // - Connect controllers to text fields
    // - Handle send button press
    // Placeholder
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: "Enter your username"),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: "Enter your message"),
          ),
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: _sendMessage, child: const Text("Send"))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () => _showHTTPStatus(200), child: const Text("200 OK"))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () => _showHTTPStatus(404), child: const Text("404 Not Found"))),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () => _showHTTPStatus(500), child: const Text("500 Error"))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    // TODO: Implement _buildErrorWidget
    // Return Center widget with:
    // - Column containing error icon, error message, and retry button
    // - Red color scheme for error state
    // - Retry button should call _loadMessages()
    // return Container(); // Placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? "Unknown error", style: const TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: _loadMessages, child: const Text("Retry")),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    // TODO: Implement _buildLoadingWidget
    // Return Center widget with CircularProgressIndicator
    // return Container(); // Placeholder
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement build method
    // Return Scaffold with:
    // - AppBar with title "REST API Chat" and refresh action
    // - Body that shows loading, error, or message list based on state
    // - BottomSheet with message input
    // - FloatingActionButton for refresh
    // Handle different states: loading, error, success
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('No messages yet'),
                          SizedBox(height: 8),
                          Text('Send your first message to get started!'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (_, i) => _buildMessageTile(_messages[i]),
                    ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  // TODO: Add static method showRandomStatus(BuildContext context, ApiService apiService)
  // Generate random status code from [200, 201, 400, 404, 500]
  // Call _showHTTPStatus with the random code
  // This demonstrates different HTTP cat images

  // TODO: Add static method showStatusPicker(BuildContext context, ApiService apiService)
  // Show dialog with buttons for different status codes
  // Allow user to pick which HTTP cat they want to see
  // Common codes: 100, 200, 201, 400, 401, 403, 404, 418, 500, 503
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final randomCode = [200, 201, 400, 404, 500][Random().nextInt(5)];
    _show(context, apiService, randomCode);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final codes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Choose HTTP Status"),
        content: Wrap(
          spacing: 8,
          children: codes.map((code) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _show(context, apiService, code);
              },
              child: Text("$code"),
            );
          }).toList(),
        ),
      ),
    );
  }

  static void _show(BuildContext context, ApiService apiService, int code) {
    showDialog(
      context: context,
      builder: (_) => FutureBuilder(
        future: apiService.getHTTPStatus(code),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const AlertDialog(content: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return AlertDialog(content: Text("Error: ${snapshot.error}"));
          }

          final result = snapshot.data as HTTPStatusResponse;
          return AlertDialog(
            title: Text("${result.statusCode} - ${result.description}"),
            content: Image.network(result.imageUrl),
          );
        },
      ),
    );
  }
}
