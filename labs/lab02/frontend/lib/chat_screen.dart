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
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription<String>? _messageSubscription;
  // TODO: Add state for messages, loading, and error
  // TODO: Subscribe to chatService.messageStream
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
      _connect();
  _messageSubscription = widget.chatService.messageStream.listen(
      (message) {
        setState(() {
          _messages.add(message);
        });
      },
      onError: (err) {
        setState(() {
          _error = 'Stream error: $err';
        });
      },
    );
  }

  Future<void> _connect() async {
    try {
      await widget.chatService.connect();
      setState(() {
        _isLoading = false;
      });
    } catch (err) {
      setState(() {
        _isLoading = false;
        _error = 'Connection error: $err';
      });
    }
  }
  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _controller.dispose();
    _messageSubscription?.cancel();
    widget.chatService.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    if (_controller.text.isEmpty) return;
    final message = _controller.text;
    try {
      await widget.chatService.sendMessage(message);
      _controller.clear();
    } catch (e) {
      setState(() {
        _error = 'Send error: $e';
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : ListView.builder(
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
                      hintText: 'Enter message',
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