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
  final TextEditingController _inputController = TextEditingController();
  final List<String> _messages = [];
  StreamSubscription<String>? _subscription;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await widget.chatService.connect();
      _subscription = widget.chatService.messageStream.listen((msg) {
        setState(() {
          _messages.add(msg);
        });
      });
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _subscription?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final msg = _inputController.text.trim();
    if (msg.isEmpty) return;
    _inputController.clear();
    try {
      await widget.chatService.sendMessage(msg);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error while sending message')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_hasError) {
      return const Scaffold(
        body: Center(child: Text('Connection error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
