import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import 'dart:math';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ApiService _apiService;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _apiService = Provider.of<ApiService>(context, listen: false);
      Provider.of<ChatProvider>(context, listen: false).loadMessages();
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
    if (username.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and message required')),
      );
      return;
    }
    final req = CreateMessageRequest(username: username, content: content);
    final provider = Provider.of<ChatProvider>(context, listen: false);
    try {
      await provider.createMessage(req);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent!')),
      );
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
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );
    if (result != null && result.trim().isNotEmpty) {
      final req = UpdateMessageRequest(content: result.trim());
      final provider = Provider.of<ChatProvider>(context, listen: false);
      await provider.updateMessage(message.id, req);
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
    if (confirm == true) {
      final provider = Provider.of<ChatProvider>(context, listen: false);
      await provider.deleteMessage(message.id);
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    final provider = Provider.of<ChatProvider>(context, listen: false);
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
              const SizedBox(height: 8),
              Image.network(status.imageUrl, height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.error)),
            ],
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(title: const Text('Error'), content: Text('$e')),
      );
    }
  }

  Widget _buildStatusButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => _showHTTPStatus(200),
          child: const Text('200 OK'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _showHTTPStatus(404),
          child: const Text('404 Not Found'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: () => _showHTTPStatus(500),
          child: const Text('500 Error'),
        ),
      ],
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username.isNotEmpty ? message.username[0].toUpperCase() : '?')),
      title: Text('${message.username}  •  ${message.timestamp.toLocal()}'),
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
        _showHTTPStatus(codes[Random().nextInt(codes.length)]);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.grey[100],
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
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildStatusButtons(),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(error, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Provider.of<ChatProvider>(context, listen: false).loadMessages(),
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
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('REST API Chat'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: provider.loadMessages),
            ],
          ),
          body: provider.isLoading
              ? _buildLoadingWidget()
              : provider.error != null
                  ? _buildErrorWidget(provider.error!)
                  : provider.messages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('No messages yet'),
                              Text('Send your first message to get started!'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: provider.messages.length,
                          itemBuilder: (context, idx) => _buildMessageTile(provider.messages[idx]),
                        ),
          bottomSheet: _buildMessageInput(),
          floatingActionButton: FloatingActionButton(
            onPressed: provider.loadMessages,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [200, 201, 400, 404, 500];
    final code = codes[Random().nextInt(codes.length)];
    _show(context, apiService, code);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick HTTP Status'),
        content: Wrap(
          spacing: 8,
          children: [100, 200, 201, 400, 401, 403, 404, 418, 500, 503]
              .map((code) => ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _show(context, apiService, code);
                    },
                    child: Text('$code'),
                  ))
              .toList(),
        ),
      ),
    );
  }

  static void _show(BuildContext context, ApiService apiService, int code) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<HTTPStatusResponse>(
        future: apiService.getHTTPStatus(code),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(content: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return AlertDialog(title: const Text('Error'), content: Text('${snapshot.error}'));
          } else if (snapshot.hasData) {
            final resp = snapshot.data!;
            return AlertDialog(
              title: Text('${resp.statusCode} ${resp.description}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(resp.description),
                  const SizedBox(height: 8),
                  Image.network(resp.imageUrl, height: 100, errorBuilder: (_, __, ___) => const Icon(Icons.error)),
                ],
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}
