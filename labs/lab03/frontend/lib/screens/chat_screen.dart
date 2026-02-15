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
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    final req = CreateMessageRequest(username: username, content: content);
    final validation = req.validate();
    if (validation != null) {
      setState(() {
        _error = validation;
      });
      return;
    }
    try {
      final msg = await _apiService.createMessage(req);
      setState(() {
        _messages.add(msg);
        _messageController.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent successfully!')),
          );
        }
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final req = UpdateMessageRequest(content: result);
      final validation = req.validate();
      if (validation != null) {
        setState(() {
          _error = validation;
        });
        return;
      }
      try {
        final updated = await _apiService.updateMessage(message.id, req);
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == message.id);
          if (idx != -1) _messages[idx] = updated;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
        });
      }
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
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
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
      builder: (context) {
        return FutureBuilder<HTTPStatusResponse>(
          future: _apiService.getHTTPStatus(statusCode),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text('HTTP Status: $statusCode'),
                content: Text('Error: ${snapshot.error}'),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
              );
            } else if (snapshot.hasData) {
              final data = snapshot.data!;
              return AlertDialog(
                title: Text('HTTP Status: ${data.statusCode}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data.description),
                    const SizedBox(height: 8),
                    Image.network(data.imageUrl, height: 120, errorBuilder: (c, e, s) => const Icon(Icons.error)),
                  ],
                ),
                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username.isNotEmpty ? message.username[0].toUpperCase() : '?')),
      title: Text('${message.username} • ${message.timestamp.toLocal().toString().substring(0, 19)}'),
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
        _showHTTPStatus(codes[Random().nextInt(codes.length)]);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Enter your message'),
                ),
              ),
              Wrap(
                spacing: 4,
                children: [
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: const Text('Send'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showHTTPStatus(200),
                    child: const Text('200 OK'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showHTTPStatus(404),
                    child: const Text('404 Not Found'),
                  ),
                  ElevatedButton(
                    onPressed: () => _showHTTPStatus(500),
                    child: const Text('500 Error'),
                  ),
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
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
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
              ? _buildErrorWidget()
              : _messages.isEmpty
                  ? const Center(child: Text('No messages yet'))
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

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [200, 201, 400, 404, 500];
    final code = codes[Random().nextInt(codes.length)];
    _showStatus(context, apiService, code);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Pick HTTP Status'),
        children: [
          for (final code in [100, 200, 201, 400, 401, 403, 404, 418, 500, 503])
            SimpleDialogOption(
              child: Text('HTTP $code'),
              onPressed: () {
                Navigator.pop(context);
                _showStatus(context, apiService, code);
              },
            ),
        ],
      ),
    );
  }

  static void _showStatus(BuildContext context, ApiService apiService, int code) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<HTTPStatusResponse>(
        future: apiService.getHTTPStatus(code),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            );
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: const Text('HTTP Status'),
              content: Text('Error: ${snapshot.error}'),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return AlertDialog(
              title: Text('HTTP ${data.statusCode}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.description),
                  const SizedBox(height: 8),
                  Image.network(data.imageUrl, height: 120, errorBuilder: (c, e, s) => const Icon(Icons.error)),
                ],
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
