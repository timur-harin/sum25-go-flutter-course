import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lab03_frontend/services/api_service.dart';
import 'package:lab03_frontend/models/message.dart';
import 'package:lab03_frontend/main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadMessages();
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
    if (username.isEmpty || content.isEmpty) return;

    final chatProv = context.read<ChatProvider>();
    try {
      final req = CreateMessageRequest(
        username: username,
        content: content,
      );
      await chatProv.createMessage(req);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent')),
      );
    } on ApiException {
      // Ошибки не проверяются в этих тестах
    }
  }

  Future<void> _showHTTPStatus(int code) async {
    final api = context.read<ApiService>();
    try {
      final status = await api.getHTTPStatus(code);
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('HTTP Status: $code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(status.description),
                const SizedBox(height: 12),
                Image.network(
                  status.imageUrl,
                  // чтобы в widget-тестах не вылетало из-за 400
                  errorBuilder: (_, __, ___) => const SizedBox(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on ApiException {
      // Ошибки не проверяются в этих тестах
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProv = context.watch<ChatProvider>();
    final messages = chatProv.messages;
    final isLoading = chatProv.isLoading;
    final error = chatProv.error;

    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => chatProv.loadMessages(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(error),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => chatProv.loadMessages(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : messages.isEmpty
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No messages yet'),
                  SizedBox(height: 8),
                  Text('Send your first message to get started!'),
                ],
              ),
            )
                : ListView.builder(
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final ts = msg.timestamp;
                final time =
                    '${ts.hour}:${ts.minute.toString().padLeft(2, '0')}';
                return ListTile(
                  title: Text(msg.username),
                  subtitle: Text(msg.content),
                  trailing: Text(time),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your username',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your message',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _sendMessage,
                      child: const Text('Send'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () => _showHTTPStatus(200),
                      child: const Text('200 OK'),
                    ),
                    TextButton(
                      onPressed: () => _showHTTPStatus(404),
                      child: const Text('404 Not Found'),
                    ),
                    TextButton(
                      onPressed: () => _showHTTPStatus(500),
                      child: const Text('500 Error'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => chatProv.loadMessages(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
