import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

class Message {
  final String text;
  final String sender;
  final DateTime timestamp;

  Message({required this.text, required this.sender, required this.timestamp});
}

class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  StreamSubscription? _subscription;
  final List<Message> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectToChat();
    // TODO: Connect to chat service and set up listeners
  }

  void _connectToChat() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.chatService.connect();

      _subscription = widget.chatService.messageStream.listen(
        (text) {
          setState(() {
            _messages.insert(
              0,
              Message(
                text: text,
                sender: text.startsWith('You:') ? 'You' : 'Other',
                timestamp: DateTime.now(),
              ),
            );
          });
        },
        onError: (error) {
          setState(() {
            _error = 'Connection error: $error';
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = 'Connection error: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _messageController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    try {
      await widget.chatService.sendMessage(text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Column(
      children: [
        Expanded(child: _buildChatContent()),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildChatContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(_error!), // ← этот Text должен содержать "Connection error"
      );
    }

    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[index];
        return ListTile(
          title: Text(msg.text),
          subtitle: Text(
            '${msg.sender} • ${msg.timestamp.toLocal().toString().substring(0, 16)}',
          ),
        );
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
