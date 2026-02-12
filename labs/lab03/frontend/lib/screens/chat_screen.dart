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
  late ApiService _apiService;
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = context.read<ApiService>();
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
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
    if (username.isEmpty || content.isEmpty) return;

    try {
      final request = CreateMessageRequest(username: username, content: content);
      final message = await _apiService.createMessage(request);
      setState(() {
        _messages.insert(0, message);
      });
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


  Future<void> _editMessage(Message message) async {
    final TextEditingController _editController =
        TextEditingController(text: message.content);

    final String? updatedContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: _editController,
          decoration: const InputDecoration(hintText: 'Enter new message content'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, _editController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (updatedContent == null || updatedContent.trim().isEmpty) return;

    try {
      final request = UpdateMessageRequest(content: updatedContent.trim());
      final updatedMessage = await _apiService.updateMessage(message.id, request);

      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = updatedMessage;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update message: $e')),
      );
    }
  }



  Future<void> _deleteMessage(Message message) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
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
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteMessage(message.id);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete message: $e')),
      );
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final status = await _apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 12),
              Image.network(
                status.imageUrl,
                errorBuilder: (_, __, ___) => const Text('Image failed to load'),
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
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load status: $e')),
      );
    }
  }


  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') _editMessage(message);
          if (value == 'delete') _deleteMessage(message);
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        final code = (codes..shuffle()).first;
        _showHTTPStatus(code);
      },
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
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Enter your message'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
              TextButton(
                onPressed: () => _showHTTPStatus(200),
                child: const Text('200 OK'),
              ),
              TextButton(
                onPressed: () => _showHTTPStatus(404),
                child: const Text('404 Not Found'),
              ),
              TextButton(
                onPressed: () => _showHTTPStatus(500),
                child: const Text('500 Error'),
              ),
            ],
          )
        ],
      ),
    );
  }


  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 10),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: _loadMessages, child: const Text('Retry'))
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
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
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('No messages yet'),
                          SizedBox(height: 10),
                          Text('Send your first message to get started!'),
                        ],
                      ),
                    )
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
  static Future<void> showRandomStatus(BuildContext context, ApiService apiService) async {
    final codes = [200, 201, 400, 404, 500];
    codes.shuffle();
    final code = codes.first;
    final state = context.findAncestorStateOfType<_ChatScreenState>();
    if (state != null) {
      await state._showHTTPStatus(code);
    }
  }

  static Future<void> showStatusPicker(BuildContext context, ApiService apiService) async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Pick a status code'),
        content: Wrap(
          spacing: 8,
          children: [100, 200, 201, 400, 401, 403, 404, 418, 500, 503].map((code) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final state = context.findAncestorStateOfType<_ChatScreenState>();
                if (state != null) {
                  state._showHTTPStatus(code);
                }
              },
              child: Text('$code'),
            );
          }).toList(),
        ),
      ),
    );
  }
}
