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
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
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
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();

    if (username.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and message are required')),
      );
      return;
    }

    try {
      final newMessage = await _apiService.createMessage(
        CreateMessageRequest(username: username, content: content),
      );
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final editedContent = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: message.content);
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (editedContent != null && editedContent != message.content) {
      try {
        final updatedMessage = await _apiService.updateMessage(
          message.id,
          UpdateMessageRequest(content: editedContent),
        );
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) {
            _messages[index] = updatedMessage;
          }
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update message: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('This action cannot be undone'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final statusInfo = await _apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(statusInfo.description),
              const SizedBox(height: 16),
              Image.network(
                'https://http.cat/$statusCode.jpg',
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, size: 100),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get HTTP status: ${e.toString()}')),
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
        ],
      ),
      subtitle: Text(message.content),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
        onSelected: (value) {
          if (value == 'edit') _editMessage(message);
          if (value == 'delete') _deleteMessage(message);
        },
      ),
      onTap: () {
        final statusCodes = [200, 404, 500];
        final randomStatus = statusCodes[Random().nextInt(statusCodes.length)];
        _showHTTPStatus(randomStatus);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Theme.of(context).cardColor,
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
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusButton(200),
              _buildStatusButton(404),
              _buildStatusButton(500),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(int statusCode) {
    return TextButton(
      onPressed: () => _showHTTPStatus(statusCode),
      child: Text('$statusCode'),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
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

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final statusCodes = [200, 201, 400, 404, 500];
    final randomStatus = statusCodes[Random().nextInt(statusCodes.length)];
    _ChatScreenState()._showHTTPStatus(randomStatus);
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
          children: statusCodes.map((code) =>
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _ChatScreenState()._showHTTPStatus(code);
                },
                child: Text('$code'),
              ),
          ).toList(),
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
