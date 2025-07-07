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
  late ApiService _apiService;
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
    final req = CreateMessageRequest(username: username, content: content);
    final validation = req.validate();
    if (validation != null) {
      _showSnackBar(validation);
      return;
    }
    setState(() {
      _isLoading = true;
    });
    try {
      final message = await _apiService.createMessage(req);
      setState(() {
        _messages.add(message);
        _messageController.clear();
      });
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      setState(() {
        _isLoading = false;
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
          ElevatedButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final req = UpdateMessageRequest(content: result.trim());
      final validation = req.validate();
      if (validation != null) {
        _showSnackBar(validation);
        return;
      }
      setState(() {
        _isLoading = true;
      });
      try {
        final updated = await _apiService.updateMessage(message.id, req);
        setState(() {
          final idx = _messages.indexWhere((m) => m.id == message.id);
          if (idx != -1) _messages[idx] = updated;
        });
      } catch (e) {
        _showSnackBar(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
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
      setState(() {
        _isLoading = true;
      });
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
        });
      } catch (e) {
        _showSnackBar(e.toString());
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final status = await _apiService.getHTTPStatus(statusCode);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 16),
              Image.network(
                status.imageUrl,
                errorBuilder: (context, error, stackTrace) => const Text('Failed to load HTTP cat'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
        final code = codes[Random().nextInt(codes.length)];
        _showHTTPStatus(code);
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
            decoration: const InputDecoration(labelText: 'Username'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _isLoading ? null : _sendMessage,
              ),
              IconButton(
                icon: const Icon(Icons.pets),
                tooltip: 'HTTP Cat Demo',
                onPressed: _isLoading
                    ? null
                    : () => HTTPStatusDemo.showRandomStatus(context, _apiService),
              ),
              IconButton(
                icon: const Icon(Icons.info),
                tooltip: 'Pick HTTP Status',
                onPressed: _isLoading
                    ? null
                    : () => HTTPStatusDemo.showStatusPicker(context, _apiService),
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
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_error ?? 'Unknown error', style: const TextStyle(color: Colors.red)),
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
            onPressed: _isLoading ? null : _loadMessages,
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
                      itemBuilder: (context, idx) => _buildMessageTile(_messages[idx]),
                    ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _loadMessages,
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
      builder: (context) => AlertDialog(
        title: const Text('Pick HTTP Status'),
        content: Wrap(
          spacing: 8,
          children: [
            for (final code in [100, 200, 201, 400, 401, 403, 404, 418, 500, 503])
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showStatus(context, apiService, code);
                },
                child: Text('$code'),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showStatus(BuildContext context, ApiService apiService, int code) async {
    try {
      final status = await apiService.getHTTPStatus(code);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 16),
              Image.network(
                status.imageUrl,
                errorBuilder: (context, error, stackTrace) => const Text('Failed to load HTTP cat'),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
