import 'package:flutter/material.dart';
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
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Call _loadMessages() to load initial data
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
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
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

    try {
      // final newMessage = await _apiService.createMessage(username, content);
      final newMessage = await _apiService.createMessage(CreateMessageRequest(username: username, content: content));
      setState(() {
        _messages.insert(0, newMessage);
        _messageController.clear();
      });
    } catch (e) {
      _error = e.toString();
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

    final editedContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new content'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (editedContent == null || editedContent.isEmpty) return;

    try {
      // final updated = await _apiService.updateMessage(message.id, editedContent);
      final updated = await _apiService.updateMessage(message.id, UpdateMessageRequest(content: editedContent));
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) _messages[index] = updated;
      });
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> _deleteMessage(Message message) async {
    // TODO: Implement _deleteMessage
    // Show confirmation dialog
    // If confirmed, try to delete using _apiService.deleteMessage()
    // Remove message from _messages list
    // Catch any exceptions and show error
    // Call setState() to update UI
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteMessage(message.id);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });
    } catch (e) {
      _error = e.toString();
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
      final description = await _apiService.getHTTPStatus(statusCode);

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(description.description),
              const SizedBox(height: 12),
              Image.network('https://http.cat/$statusCode.jpg', errorBuilder: (context, error, stack) {
                return const Text('Image not available');
              }),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error loading HTTP status image: $e');
    }
  }

  Widget _buildMessageTile(Message message) {
    // TODO: Implement _buildMessageTile
    // Return ListTile with:
    // - leading: CircleAvatar with first letter of username
    // - title: Text with username and timestamp
    // - subtitle: Text with message content
    // - trailing: PopupMenuButton with Edit and Delete options
    // - onTap: Show HTTP status dialog for random status code (200, 404, 500)
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text('${message.username} — ${message.timestamp}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editMessage(message);
          } else if (value == 'delete') {
            _deleteMessage(message);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        final randomCode = codes[Random().nextInt(codes.length)];
        _showHTTPStatus(randomCode);
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
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          Row(
            children: [
              ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => _showHTTPStatus(200), child: const Text('200')),
              ElevatedButton(onPressed: () => _showHTTPStatus(404), child: const Text('404')),
              ElevatedButton(onPressed: () => _showHTTPStatus(500), child: const Text('500')),
            ],
          )
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadMessages, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    // TODO: Implement _buildLoadingWidget
    // Return Center widget with CircularProgressIndicator
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
        title: const Text('TODO REST API Chat'),
        actions: [
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageTile(_messages[index]);
                  },
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
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [200, 201, 400, 404, 500];
    final code = codes[Random().nextInt(codes.length)];
    _showHTTPStatus(context, apiService, code);
  }

  // TODO: Add static method showRandomStatus(BuildContext context, ApiService apiService)
  // Generate random status code from [200, 201, 400, 404, 500]
  // Call _showHTTPStatus with the random code
  // This demonstrates different HTTP cat images

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose HTTP Status'),
        content: Wrap(
          spacing: 8,
          children: [100, 200, 201, 400, 401, 403, 404, 418, 500, 503].map((code) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showHTTPStatus(context, apiService, code);
              },
              child: Text('$code'),
            );
          }).toList(),
        ),
      ),
    );
  }

  // TODO: Add static method showStatusPicker(BuildContext context, ApiService apiService)
  // Show dialog with buttons for different status codes
  // Allow user to pick which HTTP cat they want to see
  // Common codes: 100, 200, 201, 400, 401, 403, 404, 418, 500, 503

  static void _showHTTPStatus(BuildContext context, ApiService apiService, int code) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<String>(
        // future: apiService.getHTTPStatus(code),
        future: apiService.getHTTPStatus(code).then((value) => value.description),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(content: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return AlertDialog(content: Text('Error: ${snapshot.error}'));
          } else {
            return AlertDialog(
              title: Text('HTTP $code'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(snapshot.data ?? ''),
                  const SizedBox(height: 8),
                  Image.network('https://http.cat/$code.jpg'),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
              ],
            );
          }
        },
      ),
    );
  }
}
