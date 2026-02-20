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
        const SnackBar(content: Text('Username and message cannot be empty.')),
      );
      return;
    }

    final request = CreateMessageRequest(username: username, content: content);
    final error = request.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    try {
      final newMessage = await _apiService.createMessage(request);
      setState(() {
        _messages.insert(0, newMessage);
      });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    final request = UpdateMessageRequest(content: result.trim());
    final error = request.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    try {
      final updatedMessage = await _apiService.updateMessage(message.id, request);
      setState(() {
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) _messages[index] = updatedMessage;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteMessage(Message message) async {
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final status = await _apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${status.statusCode} - ${status.description}'),
          content: Image.network(
            status.imageUrl,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : const CircularProgressIndicator(),
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
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
        final code = codes[message.id % codes.length];
        _showHTTPStatus(code);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey.shade200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Message'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(200),
                child: const Text('HTTP 200'),
              ),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(404),
                child: const Text('HTTP 404'),
              ),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(500),
                child: const Text('HTTP 500'),
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
          const Icon(Icons.error, color: Colors.red, size: 64),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
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
                  itemBuilder: (context, index) => _buildMessageTile(_messages[index]),
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
    final randomCode = (codes..shuffle()).first;
    final state = context.findAncestorStateOfType<_ChatScreenState>();
    state?._showHTTPStatus(randomCode);
  }

  static Future<void> showStatusPicker(BuildContext context, ApiService apiService) async {
    final codes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    final state = context.findAncestorStateOfType<_ChatScreenState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick an HTTP Status Code'),
        content: Wrap(
          spacing: 8,
          children: codes.map((code) {
            return ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                state?._showHTTPStatus(code);
              },
              child: Text('$code'),
            );
          }).toList(),
        ),
      ),
    );
  }
}