import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

// ChatScreen displays the chat UI
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // TODO: Add TextEditingController for input
  // TODO: Add state for messages, loading, and error
  // TODO: Subscribe to chatService.messageStream
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  late final TextEditingController _textController;
  StreamSubscription<String>? _subscription;
  final List<String> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _textController = TextEditingController();
    // Connect and listen
    widget.chatService.connect().then((_) {
      setState(() => _loading = false);
      _subscription = widget.chatService.messageStream.listen(
        (msg) {
          setState(() => _messages.add(msg));
        },
        onError: (err) => setState(() => _error = err.toString()),
      );
    }).catchError((err) {
      setState(() {
        _loading = false;
        _error = err.toString();
      });
    });
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _subscription?.cancel();
    _textController.dispose();
    widget.chatService.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    try {
      await widget.chatService.sendMessage(text);
      _textController.clear();
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send error: \$err')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text('Connection error: \$_error'));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (_, i) => ListTile(
              title: Text(_messages[i]),
            ),
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: const InputDecoration(hintText: 'Type a message'),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
