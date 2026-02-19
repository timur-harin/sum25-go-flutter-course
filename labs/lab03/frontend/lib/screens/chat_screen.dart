import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'dart:math';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  final List<Message> _messages = [];
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isLoading = false;
  String? _error;

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
      _messages.clear();
      _messages.addAll(messages);
      _isLoading = false;
    });
  } catch (e) {
    setState(() {
      _error = 'Failed to load messages';
      _isLoading = false;
    });
  }
}


  void _sendMessage() async {
  final username = _usernameController.text.trim();
  final content = _messageController.text.trim();

  if (username.isEmpty || content.isEmpty) return;

  try {
    await _apiService.createMessage(
      CreateMessageRequest(username: username, content: content),
    );
    _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Message sent successfully!')),
    );

    _loadMessages(); // reloads messages after send
  } catch (e) {
    setState(() => _error = 'Failed to send message');
  }
}

void _checkStatus(int code) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('HTTP Status: $code'),
      content: Image.network('http://localhost:8080/api/cat/$code'),
    ),
  );
}


  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      try {
        final updated = await _apiService.updateMessage(
          message.id,
          UpdateMessageRequest(content: result.trim()),
        );
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          setState(() => _messages[index] = updated);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() => _messages.remove(message));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.getHTTPStatus(statusCode);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${response.statusCode} ${response.description}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                response.imageUrl,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (_, __, ___) => const Icon(Icons.error),
              ),
              const SizedBox(height: 10),
              Text(response.description),
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
        builder: (_) => AlertDialog(
          title: const Text('Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('200 OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username)),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
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
      onTap: () => _showHTTPStatus([200, 404, 500][Random().nextInt(3)]),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Enter your username', 
            ),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Enter your message',
            ),
          ),

          Row(
            children: [
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const Spacer(),
             Row(
  children: [
    ElevatedButton(
      onPressed: _sendMessage,
      child: const Text('Send'),
    ),
    const Spacer(),
    ...[200, 404, 500].map((code) => IconButton(
      key: Key('status_$code '),
      icon: const Icon(Icons.info),
      onPressed: () => _showHTTPStatus(code),
    )),
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
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _loadMessages, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

@override
Widget build(BuildContext context) {
  if (_error != null) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.error_outline),
        const SizedBox(height: 8),
        const Text('Something went wrong'),
        ElevatedButton(
          onPressed: _loadMessages, // Retry logic
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}

  return Scaffold(
    appBar: AppBar(title: const Text('Chat')),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            key: const Key('usernameField'),
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Enter your username',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('messageField'),
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Enter your message',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            key: const Key('sendButton'),
            onPressed: _sendMessage,
            child: const Text('Send'),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                key: const Key('status200Button'),
                onPressed: () => _checkStatus(200),
                child: const Text('200 OK'),
              ),
              ElevatedButton(
                key: const Key('status404Button'),
                onPressed: () => _checkStatus(404),
                child: const Text('404 Not Found'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('No messages yet'),
                      Text('Send your first message to get started!'),
                    ],
                  ),
                ): ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ListTile(
                        title: Text(message.username),
                        subtitle: Text(message.content),
                      );
                    },
                  ),
          ),
          
        ],
      ),
    ),
  );
}



}




