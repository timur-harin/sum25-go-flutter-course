import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';

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
  late final ApiService _apiService = ApiService();
  late List<Message> _messages = [];
  late bool _isLoading = false;
  late bool _hasLoaded = false;
  late String? _error;
  late final TextEditingController _usernameController = TextEditingController();
  late final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Call _loadMessages() to load initial data
    _loadMessages();
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and API service
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
      _messages = messages;
    } catch (e) {
      setState(() {
        _error = "Failed to load messages: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
        _hasLoaded = true;
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
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    if(username.isEmpty){
      setState((){
        _error = "Username is empty";
      });
      return;
    }
    if(content.isEmpty){
      setState((){
          _error = "Content is empty";
      });
      return;
    }
    final request = CreateMessageRequest(
      username: username,
      content: content,
    );
    try{
      final message = await _apiService.createMessage(request);
      _messages.add(message);
      _messageController.clear();
    } catch(e){
      setState(() {
        _error = "Failed to send message: $e";
      });
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
    final TextEditingController _editController = TextEditingController(text: message.content);
    final newContent = await showDialog<String>(
        context: context,
        builder: (context){
          return AlertDialog(
            title: const Text("Edit message"),
            content: TextField(
              controller: _editController,
              decoration: const InputDecoration(
                labelText: 'New Content',
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
              ElevatedButton(onPressed: (){
                Navigator.pop(context, _editController.text);
              }, child: const Text("Save")),
            ],
          );
        }
    );
    if (newContent != null && newContent.trim().isNotEmpty) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try{
      final request = UpdateMessageRequest(content: newContent!.trim());
      final updatedMessage = await _apiService.updateMessage(message.id, request);
      setState(() {
        final idx = _messages.indexWhere((msg) => msg.id == message.id);
        if (idx != -1) {
          _messages[idx] = updatedMessage;
        }
      });
    } catch (e) {
      setState(() {
        _error = "Failed to update message: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      builder: (context) => AlertDialog(
        title: const Text('Delete message'),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      )
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((msg) => msg.id == message.id);
        });
      } catch (e) {
        setState(() {
          _error = 'Failed to delete message: $e';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
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
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final status = await _apiService.getHTTPStatus(statusCode);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 16),
              Image.network(
                status.imageUrl,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load HTTP status: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
      leading: CircleAvatar(
        child: Text(message.username.isNotEmpty ? message.username[0].toUpperCase() : '?'),
      ),
      title: Text(
        '${message.username} ${message.timestamp.toLocal().toString().split('.')[0]}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
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
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
        ],
      ),
      onTap: () {
        final randomStatus = [200, 404, 500]..shuffle();
        _showHTTPStatus(randomStatus.first);
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
      padding: const EdgeInsets.all(12.0),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(onPressed: () => _showHTTPStatus(200), child: const Text('200')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(onPressed: () => _showHTTPStatus(404), child: const Text('404')),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(onPressed: () => _showHTTPStatus(500), child: const Text('500')),
              ),
            ],
          )
        ],
      ),
    );// Placeholder
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
          const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _loadMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    // TODO: Implement _buildLoadingWidget
    // Return Center widget with CircularProgressIndicator
    return const CircularProgressIndicator(); // Placeholder
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
    if (!_hasLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('REST API Chat'),  // ← вот он
        ),
        body: const Center(
          child: Text('TODO: Implement chat functionality'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
          ? _buildErrorWidget()
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) =>
            _buildMessageTile(_messages[index]),
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
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final List<int> statusCodes = [200, 201, 400, 404, 500];
    final random = Random();
    final randomCode = statusCodes[random.nextInt(statusCodes.length)];

    _showHTTPStatus(context, apiService, randomCode);
  }


  // TODO: Add static method showStatusPicker(BuildContext context, ApiService apiService)
  // Show dialog with buttons for different status codes
  // Allow user to pick which HTTP cat they want to see
  // Common codes: 100, 200, 201, 400, 401, 403, 404, 418, 500, 503
  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final List<int> commonStatusCodes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick HTTP Status'),
        content: SingleChildScrollView(
          child: Column(
            children: commonStatusCodes.map((code) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showHTTPStatus(context, apiService, code);
                },
                child: Text('Status $code'),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  static Future<void> _showHTTPStatus(
      BuildContext context, ApiService apiService, int statusCode) async {
    try {
      final statusInfo = await apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status ${statusInfo.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(statusInfo.description),
              const SizedBox(height: 16),
              Image.network(
                statusInfo.imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to load HTTP status: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }
}
