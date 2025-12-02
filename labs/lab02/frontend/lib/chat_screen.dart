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
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];
  bool _isConnecting = true;
  String? _error;
  StreamSubscription<String>? _sub;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    super.initState();
    _connectAndListen();
  }

  Future<void> _connectAndListen() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });
    try {
      await widget.chatService.connect();
      _sub = widget.chatService.messageStream.listen((msg) {
        setState(() {
          _messages.add(msg);
        });
        // scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        });
      }, onError: (e) {
        setState(() {
          _error = e.toString();
        });
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isConnecting = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _sub?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    try {
      await widget.chatService.sendMessage(text);
      // optionally also echo local message:
      // setState(() => _messages.add(text));
    } catch (e) {
      // show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_isConnecting) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Connection error: $_error',
          style: const TextStyle(color: Colors.red),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _connectAndListen,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
    } else {
      body = Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_messages[i]),
                  ),
                ),
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
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: body,
    );
  }
}
