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
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final msgs = await _apiService.getMessages();
      setState(() {
        _messages = msgs;
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
      final msg = await _apiService.createMessage(
        CreateMessageRequest(username: username, content: content),
      );
      setState(() {
        _messages.add(msg);
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save')),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;

    try {
      final updated = await _apiService.updateMessage(
        message.id,
        UpdateMessageRequest(content: result.trim()),
      );
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == message.id);
        if (idx != -1) _messages[idx] = updated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Message?'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await _apiService.deleteMessage(message.id);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final status = await _apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 16),
              Image.network(status.imageUrl,
                  errorBuilder: (_, __, ___) =>
                      const Text('Failed to load image')),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (v) {
          if (v == 'edit') _editMessage(message);
          if (v == 'delete') _deleteMessage(message);
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        codes.shuffle();
        _showHTTPStatus(codes.first);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username')),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(labelText: 'Message'))),
              IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
              IconButton(
                  icon: const Icon(Icons.sentiment_satisfied),
                  onPressed: () => _showHTTPStatus(200)),
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
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error',
              style: const TextStyle(color: Colors.red)),
          TextButton(onPressed: _loadMessages, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    final _ = Provider.of<ApiService>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadMessages)
        ],
      ),
      body: const Center(child: Text('TODO: Implement chat functionality')),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
          onPressed: _loadMessages, child: const Icon(Icons.refresh)),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [100, 200, 201, 400, 404, 418, 500, 503];
    final code = (codes..shuffle()).first;
    apiService.getHTTPStatus(code).then((status) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 8),
              Image.network(status.imageUrl),
            ],
          ),
        ),
      );
    });
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    const codes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    showDialog(
      context: context,
      builder: (_) => SimpleDialog(
        title: const Text('Pick status'),
        children: codes
            .map((c) => SimpleDialogOption(
                  child: Text('$c'),
                  onPressed: () {
                    Navigator.pop(context);
                    HTTPStatusDemo.showRandomStatus(context, apiService);
                  },
                ))
            .toList(),
      ),
    );
  }
}
