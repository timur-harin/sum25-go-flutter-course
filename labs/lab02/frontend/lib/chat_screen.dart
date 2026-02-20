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
    late TextEditingController _controller;
    StreamSubscription<String>? _subscription;

    final List<String> _messages = [];
    bool _isLoading = false;
    String? _error;

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _controller = TextEditingController();
    Future.microtask(() => _connectAndListen());
  }

  Future<void> _connectAndListen() async {
  setState(() {
    _isLoading = true;
    _error = null;
  });

  try {
    await widget.chatService.connect();
    _subscription = widget.chatService.messageStream.listen(
      (message) => setState(() => _messages.add(message)),
      onError: (_) => setState(() => _error = 'Connection error'),
    );
  } catch (e) {
    setState(() => _error = 'Connection error');
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.chatService.sendMessage(text);
      setState(() {
        _controller.clear();
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

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (_isLoading)
            const LinearProgressIndicator(),

          if (_error != null)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.white),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
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
          ),
        ],
      ),
    );
  }
}