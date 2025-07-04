import 'dart:math';

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
  late final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    try {
      _apiService.dispose();
    } catch (_) {}
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
        _error = 'Failed to load messages';
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
      setState(() {
        _error = "Username and message must not be empty";
      });
      return;
    }

    final createRequest = CreateMessageRequest(username: username, content: content);
    final validationError = createRequest.validate();
    if (validationError != null) {
      setState(() {
        _error = validationError;
      });
      return;
    }

    try {
      final newMessage = await _apiService.createMessage(createRequest);
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to send message';
      });
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Message'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent == null || newContent.isEmpty) return;

    final updateRequest = UpdateMessageRequest(content: newContent);
    final validationError = updateRequest.validate();
    if (validationError != null) {
      setState(() {
        _error = validationError;
      });
      return;
    }

    try {
      final updatedMessage = await _apiService.updateMessage(message.id, updateRequest);
      setState(() {
        final index = _messages.indexWhere((m) => m.id == updatedMessage.id);
        if (index != -1) {
          _messages[index] = updatedMessage;
          _error = null;
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to update message';
      });
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
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _apiService.deleteMessage(message.id);
      setState(() {
        _messages.removeWhere((m) => m.id == message.id);
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to delete message';
      });
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final info = await _apiService.getHTTPStatus(statusCode);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.description),
              const SizedBox(height: 12),
              Image.network(
                info.imageUrl,
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Failed to load image'),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load HTTP status info';
      });
    }
  }

  Widget _buildMessageTile(Message message) {
    final timestampStr = message.timestamp.toLocal().toIso8601String().substring(0, 19);
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username.isNotEmpty ? message.username[0].toUpperCase() : '?'),
      ),
      title: Text('${message.username} $timestampStr'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editMessage(message);
          } else if (value == 'delete') {
            _deleteMessage(message);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        final randomCode = codes[Random().nextInt(codes.length)];
        _showHTTPStatus(randomCode);
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
            children: [
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => HTTPStatusDemo.showStatusPicker(context, _apiService),
                child: const Text('Show HTTP Cat'),
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
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 8),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Retry'),
          ),
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
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? _buildLoadingWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) => _buildMessageTile(_messages[index]),
                    ),
          const Center(
            child: Text(
              'TODO',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [200, 201, 400, 404, 500];
    final code = codes[Random().nextInt(codes.length)];
    _showHTTPStatus(context, apiService, code);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final codes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select HTTP Status'),
        content: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            children: codes
                .map(
                  (code) => ElevatedButton(
                    child: Text(code.toString()),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _showHTTPStatus(context, apiService, code);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  static Future<void> _showHTTPStatus(BuildContext context, ApiService apiService, int statusCode) async {
    try {
      final info = await apiService.getHTTPStatus(statusCode);

      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(info.description),
              const SizedBox(height: 12),
              Image.network(
                info.imageUrl,
                height: 150,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Failed to load image'),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const CircularProgressIndicator();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } catch (_) {
      // silently ignore errors here
    }
  }
}
