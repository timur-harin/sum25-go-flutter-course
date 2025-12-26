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
  final _controller = TextEditingController();
  final List<String> _messages = [];
  StreamSubscription<String>? _sub;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectAndListen();
  }

  Future<void> _connectAndListen() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.chatService.connect();
      _sub = widget.chatService.messageStream.listen((msg) {
        setState(() {
          _messages.add(msg);
        });
      });
      setState(() {
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
      // Сообщение появится через stream (см. тесты и mock)
    } catch (e) {
      setState(() {
        _error = 'Send error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Chat')),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: const Key('chat-list'),
              itemCount: _messages.length,
              itemBuilder: (context, idx) => ListTile(
                title: Text(_messages[idx]),
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
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
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
      ),
    );
  }
}
