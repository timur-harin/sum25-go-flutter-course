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
  // TextEditingController for input
  final TextEditingController _controller = TextEditingController();
  // State for messages, loading, and error
  final List<String> _messages = [];
  bool _isLoading = false;
  String? _error;
  // Subscription to chatService.messageStream
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    // Connect to chat service and set up listeners
    _subscription = widget.chatService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    }, onError: (e) {
      setState(() {
        // Show error message containing 'Connection error:' for test compatibility
        _error = e.toString().contains('Connection error:')
            ? e.toString()
            : 'Connection error: $e';
      });
    });
    widget.chatService.connect().catchError((e) {
      setState(() {
        // Show error message containing 'Connection error:' for test compatibility
        _error = e.toString().contains('Connection error:')
            ? e.toString()
            : 'Connection error: $e';
      });
    });
  }

  @override
  void dispose() {
    // Dispose controllers and subscriptions
    _controller.dispose();
    _subscription?.cancel();
    widget.chatService.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // Send message using chatService
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
    } catch (e) {
      setState(() {
        // Show error message containing 'Connection error:' for test compatibility
        _error = e.toString().contains('Connection error:')
            ? e.toString()
            : 'Connection error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_messages[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        const InputDecoration(hintText: 'Type a message'),
                    enabled: !_isLoading,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
