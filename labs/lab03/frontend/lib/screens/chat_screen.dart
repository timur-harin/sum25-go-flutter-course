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
      setState(() {
        _error = "Username and message cannot be empty";
      });
      return;
    }
    final request = CreateMessageRequest(username: username, content: content);
    try {
      final newMessage = await _apiService.createMessage(request);
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Content'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && result != message.content) {
      final request = UpdateMessageRequest(content: result);
      try {
        final updated = await _apiService.updateMessage(message.id, request);
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == message.id);
          if (idx != -1) _messages[idx] = updated;
          _error = null;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
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
    if (confirmed == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
          _error = null;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FutureBuilder<HTTPStatusResponse>(
          future: _apiService.getHTTPStatus(statusCode),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('HTTP Status'),
                content: Text('Error: ${snapshot.error}'),
              );
            }
            final status = snapshot.data!;
            return AlertDialog(
              title: Text('HTTP ${status.statusCode}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status.description),
                  const SizedBox(height: 12),
                  Image.network(
                    status.imageUrl,
                    height: 120,
                    errorBuilder: (c, e, s) => const Icon(Icons.error, size: 80, color: Colors.red),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username.isNotEmpty ? message.username[0].toUpperCase() : '?'),
      ),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
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
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final codes = [200, 404, 500];
        final code = codes[Random().nextInt(codes.length)];
        _showHTTPStatus(code);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.pets),
                tooltip: 'HTTP Cat',
                onPressed: () => HTTPStatusDemo.showStatusPicker(context, _apiService),
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
          const SizedBox(height: 12),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
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
        title: const Text('TODO REST API Chat'),
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
                  ? const Center(child: Text('No messages yet.'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, idx) => _buildMessageTile(_messages[idx]),
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
    final codes = [200, 201, 400, 404, 500];
    final code = codes[Random().nextInt(codes.length)];
    _showHTTPStatus(context, apiService, code);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final codes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick HTTP Status'),
        children: codes
            .map(
              (code) => SimpleDialogOption(
                child: Text('HTTP $code'),
                onPressed: () {
                  Navigator.pop(context);
                  _showHTTPStatus(context, apiService, code);
                },
              ),
            )
            .toList(),
      ),
    );
  }

  static void _showHTTPStatus(BuildContext context, ApiService apiService, int code) {
    // This method should match the _showHTTPStatus implementation in ChatScreen
    // For DRY code, you may want to refactor and share the dialog logic
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return FutureBuilder<HTTPStatusResponse>(
          future: apiService.getHTTPStatus(code),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(
                  height: 80,
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }
            if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('HTTP Status'),
                content: Text('Error: ${snapshot.error}'),
              );
            }
            final status = snapshot.data!;
            return AlertDialog(
              title: Text('HTTP ${status.statusCode}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status.description),
                  const SizedBox(height: 12),
                  Image.network(
                    status.imageUrl,
                    height: 120,
                    errorBuilder: (c, e, s) => const Icon(Icons.error, size: 80, color: Colors.red),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
