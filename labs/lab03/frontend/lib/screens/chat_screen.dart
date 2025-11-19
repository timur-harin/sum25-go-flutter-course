import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../main.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Автоматическая загрузка сообщений через Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(BuildContext context) async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();

    if (username.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and message')),
      );
      return;
    }

    try {
      final request = CreateMessageRequest(username: username, content: content);
      await Provider.of<ChatProvider>(context, listen: false).createMessage(request);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _editMessage(BuildContext context, Message message) async {
    final TextEditingController editController =
        TextEditingController(text: message.content);

    final String? newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Message content'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent != null && newContent.isNotEmpty) {
      try {
        final request = UpdateMessageRequest(content: newContent);
        await Provider.of<ChatProvider>(context, listen: false)
            .updateMessage(message.id, request);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating message: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(BuildContext context, Message message) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: Text(
            'Are you sure you want to delete this message?\n\n"${message.content}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<ChatProvider>(context, listen: false)
            .deleteMessage(message.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting message: $e')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(BuildContext context, int statusCode) async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final statusResponse = await apiService.getHTTPStatus(statusCode);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: $statusCode'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusResponse.description),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 300, maxHeight: 200),
                  child: Image.network(
                    statusResponse.imageUrl,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Failed to load image'),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading HTTP status: $e')),
        );
      }
    }
  }

  Widget _buildMessageTile(BuildContext context, Message message) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Row(
        children: [
          Text(message.username),
          const SizedBox(width: 8),
          Text(
            _formatTimestamp(message.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              _editMessage(context, message);
              break;
            case 'delete':
              _deleteMessage(context, message);
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 8),
                Text('Edit'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 8),
                Text('Delete', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        final random = Random();
        final statusCodes = [200, 404, 500];
        final randomCode = statusCodes[random.nextInt(statusCodes.length)];
        _showHTTPStatus(context, randomCode);
      },
    );
  }

  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Enter your username',
              hintText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your message',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(context),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _sendMessage(context),
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showHTTPStatus(context, 200),
                  child: const Text('200 OK'),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showHTTPStatus(context, 404),
                  child: const Text('404 Not Found'),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showHTTPStatus(context, 418),
                  child: const Text("418 I'm a teapot"),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showHTTPStatus(context, 500),
                  child: const Text('500 Error'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading messages',
            style: TextStyle(
              fontSize: 18,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error ?? 'Unknown error',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Provider.of<ChatProvider>(context, listen: false).loadMessages(),
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

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<ChatProvider>(context, listen: false).loadMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, chatProvider, _) {
                if (chatProvider.isLoading) {
                  return _buildLoadingWidget();
                } else if (chatProvider.error != null) {
                  return _buildErrorWidget(context, chatProvider.error);
                } else if (chatProvider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text('No messages yet'),
                        SizedBox(height: 8),
                        Text('Send your first message to get started!'),
                      ],
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageTile(context, chatProvider.messages[index]);
                    },
                  );
                }
              },
            ),
          ),
          _buildMessageInput(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<ChatProvider>(context, listen: false).loadMessages(),
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh',
      ),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final random = Random();
    final statusCodes = [200, 201, 400, 404, 500];
    final randomCode = statusCodes[random.nextInt(statusCodes.length)];

    // This would be called from the chat screen
    // For now, we'll handle it directly in the chat screen
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final statusCodes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select HTTP Status'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statusCodes.map((code) {
            return ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // This would call _showHTTPStatus in the chat screen
              },
              child: Text(code.toString()),
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
