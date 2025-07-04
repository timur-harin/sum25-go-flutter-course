import 'dart:math';
import 'package:flutter/material.dart';
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
    setState(() { _isLoading = true; _error = null; });
    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    if (username.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username and content cannot be empty')));
      return;
    }
    final request = CreateMessageRequest(username: username, content: content);
    final validationError = request.validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationError)));
      return;
    }
    try {
      final message = await _apiService.createMessage(request);
      setState(() { _messages.add(message); });
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: 'Content')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final request = UpdateMessageRequest(content: result);
      final validationError = request.validate();
      if (validationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(validationError)));
        return;
      }
      try {
        final updated = await _apiService.updateMessage(message.id, request);
        setState(() {
          final index = _messages.indexWhere((m) => m.id == message.id);
          if (index != -1) _messages[index] = updated;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())));
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
        ],
      ),
    );
    if (confirmed == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() { _messages.removeWhere((m) => m.id == message.id); });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final status = await _apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP ${status.statusCode}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(status.description),
            const SizedBox(height: 16),
            Image.network(status.imageUrl),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text("${message.username} • ${message.timestamp.toLocal().toString().split('.').first}"),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') _editMessage(message);
          if (value == 'delete') _deleteMessage(message);
        },
        itemBuilder: (_) => [PopupMenuItem(value: 'edit', child: Text('Edit')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
      ),
      onTap: () => HTTPStatusDemo.showRandomStatus(context, _apiService),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _usernameController, decoration: const InputDecoration(labelText: 'Username')),
        TextField(controller: _messageController, decoration: const InputDecoration(labelText: 'Message')),
        const SizedBox(height: 8),
        Row(children: [
          ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () => _showHTTPStatus(200), child: const Text('HTTP 200')),
          const SizedBox(width: 4),
          ElevatedButton(onPressed: () => _showHTTPStatus(404), child: const Text('HTTP 404')),
          const SizedBox(width: 4),
          ElevatedButton(onPressed: () => _showHTTPStatus(500), child: const Text('HTTP 500')),
        ]),
      ]),
    );
  }

  Widget _buildErrorWidget() {
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.error, size: 48, color: Colors.red),
      const SizedBox(height: 8),
      Text(_error ?? 'Unknown error'),
      const SizedBox(height: 8),
      ElevatedButton(
        onPressed: _loadMessages,
        child: const Text('Retry'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      ),
    ]));
  }

  Widget _buildLoadingWidget() => const Center(child: CircularProgressIndicator());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TODO: Implement chat functionality'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          )
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : (_error != null
          ? _buildErrorWidget()
          : (_messages.isEmpty
          ? const Center(
        child: Text('TODO'),
      )
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (_, i) =>
            _buildMessageTile(_messages[i]),
      ))),
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
    final codes = [100, 200, 201, 400, 404, 418, 500, 503];
    final code = codes[Random().nextInt(codes.length)];
    _showStatus(context, apiService, code);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Pick HTTP Status'),
      content: Wrap(spacing: 8, children: [100,200,201,400,401,403,404,418,500,503].map((c) => ElevatedButton(
        onPressed: () { Navigator.pop(context); _showStatus(context, apiService, c); },
        child: Text(c.toString()),
      )).toList()),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ));
  }

  static Future<void> _showStatus(BuildContext context, ApiService apiService, int code) async {
    try {
      final status = await apiService.getHTTPStatus(code);
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text('HTTP ${status.statusCode}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(status.description), const SizedBox(height: 16), Image.network(status.imageUrl)
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}