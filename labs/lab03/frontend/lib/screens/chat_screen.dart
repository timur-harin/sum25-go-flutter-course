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
   
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and API service
    _usernameController.dispose();
    _messageController.dispose();
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

  if (username.isEmpty || content.isEmpty) {
    setState(() {
      _error = 'Username and message cannot be empty';
    });
    return;
  }

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final request = CreateMessageRequest(username: username, content: content);
    final newMessage = await _apiService.createMessage(request);
    _messages.add(newMessage);
    _messageController.clear();
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

  final result = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Message'),
      content: TextField(
        controller: _editController,
        decoration: const InputDecoration(
          labelText: 'Message Content',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _editController.text.trim()),
          child: const Text('Save'),
        ),
      ],
    ),
  );

  if (result == null || result.isEmpty) return;

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    final request = UpdateMessageRequest(content: result);
    final updatedMessage = await _apiService.updateMessage(message.id, request);
    final index = _messages.indexWhere((m) => m.id == message.id);
    if (index != -1) {
      setState(() {
        _messages[index] = updatedMessage;
      });
    }
  } catch (e) {
    setState(() {
      _error = e.toString();
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }

  _editController.dispose();
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
      title: const Text('Delete Message'),
      content: const Text('Are you sure you want to delete this message?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    await _apiService.deleteMessage(message.id);
    setState(() {
      _messages.removeWhere((m) => m.id == message.id);
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
        title: Text('HTTP Status $statusCode'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(status.description),
            const SizedBox(height: 16),
            Image.network(
              status.imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) => const Text(
                'Failed to load HTTP cat image',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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

  Widget _buildMessageTile(Message message) {
    // TODO: Implement _buildMessageTile
    // Return ListTile with:
    // - leading: CircleAvatar with first letter of username
    // - title: Text with username and timestamp
    // - subtitle: Text with message content
    // - trailing: PopupMenuButton with Edit and Delete options
    // - onTap: Show HTTP status dialog for random status code (200, 404, 500)
    // Placeholder
  return ListTile(
    leading: CircleAvatar(
      child: Text(message.username.isNotEmpty ? message.username[0].toUpperCase() : '?'),
    ),
    title: Text('${message.username} • ${message.timestamp.toLocal().toString().substring(0, 16)}'),
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
      final randomStatusCodes = [200, 404, 500];
      final randomStatus = randomStatusCodes[DateTime.now().microsecond % randomStatusCodes.length];
      _showHTTPStatus(randomStatus);
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
    padding: const EdgeInsets.all(16),
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _sendMessage,
              child: const Text('Send'),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(200),
                  child: const Text('200'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(404),
                  child: const Text('404'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(500),
                  child: const Text('500'),
                ),
              ],
            ),
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
     // Placeholder
    return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 48,
        ),
        const SizedBox(height: 16),
        Text(
          _error ?? 'An error occurred',
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loadMessages,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

  Widget _buildLoadingWidget() {
    // TODO: Implement _buildLoadingWidget
    // Return Center widget with CircularProgressIndicator
    return const Center(
    child: CircularProgressIndicator(),
  );
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
        title: const Text('TODO: Implement ChatScreen'),
      ),
      body: const Center(
        child: Text('TODO: Implement chat functionality'),
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
    final randomStatusCodes = [200, 201, 400, 404, 500];
    final random = randomStatusCodes[DateTime.now().microsecond % randomStatusCodes.length];
    final state = context.findAncestorStateOfType<_ChatScreenState>();
    state?._showHTTPStatus(random);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select HTTP Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final code in [100, 200, 201, 400, 401, 403, 404, 418, 500, 503])
                ListTile(
                  title: Text('Status $code'),
                  onTap: () {
                    Navigator.pop(context);
                    final state = context.findAncestorStateOfType<_ChatScreenState>();
                    state?._showHTTPStatus(code);
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
