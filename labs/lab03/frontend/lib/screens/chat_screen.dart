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
    // Load messages when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        try {
          final chatProvider = context.read<ChatProvider>();
          // Only load if not already loading and no messages
          if (!chatProvider.isLoading && chatProvider.messages.isEmpty && chatProvider.error == null) {
            chatProvider.loadMessages();
          }
        } catch (e) {
          // Provider might not be available yet, will be handled in build
        }
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
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
      await context.read<ChatProvider>().createMessage(request);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final TextEditingController editController = TextEditingController(text: message.content);
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(labelText: 'Message'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(editController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      try {
        final request = UpdateMessageRequest(content: result);
        await context.read<ChatProvider>().updateMessage(message.id, request);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message updated successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating message: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await context.read<ChatProvider>().deleteMessage(message.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting message: $e')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final apiService = context.read<ChatProvider>().apiService;
      final statusResponse = await apiService.getHTTPStatus(statusCode);
      
      if (!mounted) return;
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(statusResponse.description),
              const SizedBox(height: 16),
              Image.network(
                statusResponse.imageUrl,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error, size: 100, color: Colors.red);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading HTTP status: $e')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username[0].toUpperCase()),
      ),
      title: Row(
        children: [
          Text(message.username),
          const SizedBox(width: 8),
          Text(
            _formatTimestamp(message.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
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
        _showHTTPStatus(randomCode);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Enter your username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Enter your message',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(200),
                child: const Text('200 OK'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(404),
                child: const Text('404 Not Found'),
              ),
              const SizedBox(width: 4),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(500),
                child: const Text('500 Error'),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading messages',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.watch<ChatProvider>().error ?? 'Unknown error',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<ChatProvider>().loadMessages(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Send your first message to get started!',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            onPressed: () => context.read<ChatProvider>().loadMessages(),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, chatProvider, child) {
          if (chatProvider.isLoading) {
            return _buildLoadingWidget();
          } else if (chatProvider.error != null) {
            return _buildErrorWidget();
          } else if (chatProvider.messages.isEmpty) {
            return _buildEmptyState();
          } else {
            return ListView.builder(
              itemCount: chatProvider.messages.length,
              itemBuilder: (context, index) {
                return _buildMessageTile(chatProvider.messages[index]);
              },
            );
          }
        },
      ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<ChatProvider>().loadMessages(),
        child: const Icon(Icons.refresh),
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
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Random status code: $randomCode')),
    );
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final statusCodes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select HTTP Status Code'),
        content: Wrap(
          spacing: 8,
          children: statusCodes.map((code) => ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Selected status code: $code')),
              );
            },
            child: Text(code.toString()),
          )).toList(),
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
