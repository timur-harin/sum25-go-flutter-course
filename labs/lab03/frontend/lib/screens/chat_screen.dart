import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
    _apiService.dispose();
    _usernameController.dispose();
    _messageController.dispose();
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
    final username = _usernameController.text;
    final content = _messageController.text;

    final request = CreateMessageRequest(username: username, content: content);
    final validationError = request.validate();

    if (validationError != null) {
      setState(() => _error = validationError);
      return;
    }

    try {
      final message = await _apiService.createMessage(request);
      setState(() {
        _messages.add(message);
        _messageController.clear();
        _error = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } catch (e) {
      setState(() {
        _error = 'Error sending message: $e';
      });
    }
  }

  Future<void> _showHTTPStatus(int code) async {
    try {
      final status = await _apiService.getHTTPStatus(code);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 12),
              Image.network(status.imageUrl, height: 150),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Failed to load status: $e';
      });
    }
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error ?? 'Unknown error'),
          const SizedBox(height: 8),
          TextButton(onPressed: _loadMessages, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text('${message.username}'),
      subtitle: Text(message.content),
      onTap: () => _showHTTPStatus(200),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('usernameField'),
            controller: _usernameController,
            decoration: const InputDecoration(hintText: 'Enter your username'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('messageField'),
                  controller: _messageController,
                  decoration: const InputDecoration(hintText: 'Enter your message'),
                ),
              ),
              TextButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => _showHTTPStatus(200),
                child: const Text('200 OK'),
              ),
              OutlinedButton(
                onPressed: () => _showHTTPStatus(404),
                child: const Text('404 Not Found'),
              ),
              OutlinedButton(
                onPressed: () => _showHTTPStatus(500),
                child: const Text('500 Error'),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _buildErrorWidget()
          : _messages.isEmpty
          ? const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No messages yet'),
            SizedBox(height: 8),
            Text('Send your first message to get started!'),
          ],
        ),
      )
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
