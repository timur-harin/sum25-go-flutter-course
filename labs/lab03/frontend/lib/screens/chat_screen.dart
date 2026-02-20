import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late final ApiService _apiService;
  late final ChatProvider _chatProvider;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.loadMessages();
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
    if (username.isEmpty || content.isEmpty) return;
    try {
      await _chatProvider.createMessage(username, content);
      _messageController.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Message sent')));
    } catch (_) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Error sending message')));
    }
  }

  Future<void> _showHTTPStatus(int code) async {
    try {
      final status = await _apiService.getHTTPStatus(code);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: \${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              Image.network(status.imageUrl),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (_) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to load status'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          Text(_chatProvider.error ?? 'Error occurred'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _chatProvider.loadMessages(),
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
            onPressed: () => _chatProvider.loadMessages(),
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) return _buildLoadingWidget();
          if (provider.error != null) return _buildErrorWidget();
          if (provider.messages.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('No messages yet'),
                  SizedBox(height: 4),
                  Text('Send your first message to get started!'),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: provider.messages.length,
            itemBuilder: (context, index) {
              final msg = provider.messages[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(msg.username.isNotEmpty
                      ? msg.username[0]
                      : '?'),
                ),
                title: Text(msg.username),
                subtitle: Text(msg.content),
                onTap: () => _showHTTPStatus(200),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: 'Enter your username',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Enter your message',
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
                  onPressed: () => _showHTTPStatus(200),
                  child: const Text('200 OK'),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(404),
                  child: const Text('404 Not Found'),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(500),
                  child: const Text('500 Error'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _chatProvider.loadMessages(),
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
