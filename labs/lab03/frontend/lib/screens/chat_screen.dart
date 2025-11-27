import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/message.dart';
import '../services/api_service.dart';
import '../providers/chat_provider.dart'; // импорт ChatProvider

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _messageController = TextEditingController();

    // Запускаем загрузку сообщений через провайдер
    WidgetsBinding.instance.addPostFrameCallback((_) {
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
    final username = _usernameController.text;
    final content = _messageController.text;

    final provider = Provider.of<ChatProvider>(context, listen: false);
    final success = await provider.sendMessage(username, content);

    if (success) {
      _messageController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sent')),
      );
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    final provider = Provider.of<ChatProvider>(context, listen: false);
    try {
      final status = await provider.getHTTPStatus(statusCode);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('HTTP Status: ${status?.statusCode ?? ''}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(status?.description ?? ''),
                if (status?.imageUrl != null)
                  Image.network(status!.imageUrl),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              )
            ],
          );
        },
      );
    } catch (_) {
      // игнорируем ошибку
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0])),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
      subtitle: Text(message.content),
      onTap: () => _showHTTPStatus(200),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[100],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Enter your username'),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: 'Enter your message'),
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
    );
  }

  Widget _buildErrorWidget(String? error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          Text(error ?? 'Unknown error'),
          ElevatedButton(
            onPressed: onRetry,
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
    final provider = Provider.of<ChatProvider>(context);
    final messages = provider.messages;
    final isLoading = provider.isLoading;
    final error = provider.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadMessages,
          ),
        ],
      ),
      body: isLoading
          ? _buildLoadingWidget()
          : error != null
              ? _buildErrorWidget(error, provider.loadMessages)
              : messages.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('No messages yet'),
                          Text('Send your first message to get started!'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (_, i) => _buildMessageTile(messages[i]),
                    ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: provider.loadMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
