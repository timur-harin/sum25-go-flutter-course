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
  final TextEditingController _inputController = TextEditingController();
  // TODO: Add state for messages, loading, and error
  final List<String> _messages = [];
  bool _loading = false;
  String? _error;
  // TODO: Subscribe to chatService.messageStream
  StreamSubscription<String>? _messageStreamSubscription;
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _connectToChatService();
    _messageStreamSubscription = widget.chatService.messageStream.listen((String msg) {setState(() {
      _messages.add(msg);
    });});
  }

  Future<void> _connectToChatService() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.chatService.connect();
      setState(() {
        _loading = false;
      });
    }
    catch (e) {
      setState(() {
        _loading = false;
        _error = "Connection error: $e";
      });
    }
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _messageStreamSubscription?.cancel();
    _inputController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final msg = _inputController.text;
    _inputController.clear();

    if (msg.isEmpty) {
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.chatService.sendMessage(msg);
    }
    catch (e) {
      setState(() {
        _error = "Sending message error: $e";
      });
    }

    setState(() {
    _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) Text(_error!),
          Expanded(child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(_messages[index]));
            },
          )),
          Row(
            children: [
              Expanded(child: TextField(
                controller: _inputController,
                decoration: const InputDecoration(hintText: "Type a message..."),
                onSubmitted: (_) => _sendMessage(),
              ))
            ],
          ),
          IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
        ],
      )
    );
  }
}
