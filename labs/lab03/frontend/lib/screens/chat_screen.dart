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
  final ApiService _apiService = ApiService();
  // TODO: Add List<Message> _messages = [];
  List<Message> _messages = [];
  // TODO: Add bool _isLoading = false;
  bool _isLoading = false;
  // TODO: Add String? _error;
  String? _error;
  // TODO: Add final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  // TODO: Add final TextEditingController _messageController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
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
        _error = 'Failed to load messages: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    // TODO: Implement _sendMessage
    final content = _messageController.text.trim();
    final username = _usernameController.text.trim();

    if (content.isEmpty || username.isEmpty) {
      setState(() {
        _error = 'Username and message cannot be empty.';
      });
      return;
    }

    CreateMessageRequest messageRequest = CreateMessageRequest(content: content, username: username);

    try {
      final newMessage = await _apiService.createMessage(messageRequest);

      setState(() {
        _messages.add(newMessage); // Add new message to the list
        _messageController.clear(); // Clear input field
      });
    } catch (e) {
      setState(() {
        _error = 'Error during sending message: $e';
      });
    }
  }

  Future<void> _editMessage(Message message) async {
    final contentController = TextEditingController(text: message.content);

    final updatedContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: contentController,
          decoration: const InputDecoration(hintText: 'Edit message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(contentController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedContent == null || updatedContent.isEmpty) return;

    final updateMessageRequest = UpdateMessageRequest(content: updatedContent);

    try {
      final updatedMessage = await _apiService.updateMessage(message.id, updateMessageRequest);

      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = updatedMessage;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to update message: $e';
      });
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
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
      setState(() {
        _error = 'Failed to delete message: $e';
      });
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final httpStatus = await _apiService.getHTTPStatus(statusCode);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(httpStatus.description),
              const SizedBox(height: 10),
              Image.network(
                'https://http.cat/$statusCode', // URL for HTTP cat images
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to get HTTP status: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username[0].toUpperCase()),
      ),
      title: Text('${message.username} - ${message.timestamp.toLocal()}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (action) async {
          if (action == 'Edit') {
            await _editMessage(message);
          } else if (action == 'Delete') {
            await _deleteMessage(message);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem<String>(
            value: 'Edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem<String>(
            value: 'Delete',
            child: Text('Delete'),
          ),
        ],
      ),
      onTap: () {
        final statusCodes = [200, 404, 500];
        final randomStatusCode = (statusCodes..shuffle()).first;
        _showHTTPStatus(randomStatusCode);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Message'),
            maxLines: null, // Allows multi-line input
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.http),
                    onPressed: () => _showHTTPStatus(200),
                  ),
                  IconButton(
                    icon: const Icon(Icons.http),
                    onPressed: () => _showHTTPStatus(404),
                  ),
                  IconButton(
                    icon: const Icon(Icons.http),
                    onPressed: () => _showHTTPStatus(500),
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 40),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
          ),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('REST API Chat'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadMessages,
        ),
      ],
    ),
    body: _isLoading
        ? _buildLoadingWidget()
        : _error != null
            ? _buildErrorWidget()
            : _messages.isEmpty
                ? const Center(child: Text('No messages yet'))
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
    final statusCodes = [200, 201, 400, 404, 500];
    final randomStatusCode = (statusCodes..shuffle()).first;
    _showHTTPStatus(context, apiService, randomStatusCode);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an HTTP Status Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var code in [100, 200, 201, 400, 401, 403, 404, 418, 500, 503])
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showHTTPStatus(context, apiService, code);
                },
                child: Text('Status Code $code'),
              ),
          ],
        ),
      ),
    );
  }

  static void _showHTTPStatus(
      BuildContext context, ApiService apiService, int statusCode) async {
    try {
      final httpStatus = await apiService.getHTTPStatus(statusCode);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(httpStatus.description),
              const SizedBox(height: 10),
              Image.network(
                'https://http.cat/$statusCode', // URL for HTTP cat images
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              (loadingProgress.expectedTotalBytes ?? 1)
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Text('Failed to load image');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Failed to fetch HTTP status: $e');
    }
  }
}
