import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ChatProvider _provider;
  final _usernameController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<ChatProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadMessages();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    final req = CreateMessageRequest(username: username, content: content);
    final err = req.validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    try {
      await _provider.createMessage(req);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message sent')),
        );
      }
      _messageController.clear();
    } catch (_) {
      // Do not show success message when an exception occurs
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    if (result != null) {
      await _provider.updateMessage(
          message.id, UpdateMessageRequest(content: result));
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await _provider.deleteMessage(message.id);
    }
  }

  Future<void> _showHTTPStatus(int code) async {
    final api = Provider.of<ApiService>(context, listen: false);
    try {
      final status = await api.getHTTPStatus(code);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                status.imageUrl,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.error_outline, color: Colors.red),
              ),
              Image.network(status.imageUrl),
              const SizedBox(height: 8),
              Text(status.description),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Widget _buildMessageTile(Message m) {
    return ListTile(
      leading: CircleAvatar(child: Text(m.username[0].toUpperCase())),
      title: Text('${m.username} @ ${m.timestamp}'),
      subtitle: Text(m.content),
      onTap: () {
        const codes = [200, 404, 500];
        final code = codes[Random().nextInt(codes.length)];
        _showHTTPStatus(code);
      },
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editMessage(m);
          } else if (value == 'delete') {
            _deleteMessage(m);
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }

  Widget _buildInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration:
                      const InputDecoration(labelText: 'Enter your message'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: _sendMessage, child: const Text('Send')),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                  onPressed: () => _showHTTPStatus(200),
                  child: const Text('200 OK')),
              TextButton(
                  onPressed: () => _showHTTPStatus(404),
                  child: const Text('404 Not Found')),
              TextButton(
                  onPressed: () => _showHTTPStatus(500),
                  child: const Text('500 Error')),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: state.refreshMessages,
          ),
        ],
      ),
      body: Builder(
        builder: (_) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(state.error!),
                  const SizedBox(height: 8),
                  ElevatedButton(
                      onPressed: state.loadMessages,
                      child: const Text('Retry')),
                ],
              ),
            );
          }
          if (state.messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No messages yet'),
                  Text('Send your first message to get started!'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: state.messages.length,
            itemBuilder: (_, i) => _buildMessageTile(state.messages[i]),
          );
        },
      ),
      bottomSheet: _buildInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: state.refreshMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

