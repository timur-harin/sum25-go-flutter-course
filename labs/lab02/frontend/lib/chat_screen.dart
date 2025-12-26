
import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;

  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _controller;
  StreamSubscription<String>? _subscription;

  final List<String> _messages = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initializeConnection();
    _subscription = widget.chatService.messageStream.listen(
      (msg) {
        setState(() {
          _messages.add(msg);
        });
      },
      onError: (err) {
        setState(() {
          _error = err.toString();
        });
      },
    );
  }

  Future<void> _initializeConnection() async {
    try {
      await widget.chatService.connect();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription?.cancel();
    widget.chatService.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    try {
      await widget.chatService.sendMessage(text);
    } catch (e) {
      setState(() {
        _messages.add('Error: ${e.toString()}');
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
        appBar: AppBar(title: Text('Chat')),
        body: Center(child: Text('Connection error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (ctx, i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(_messages[i]),
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
                    onSubmitted: (_) => _sendMessage(),
                    decoration:
                        InputDecoration(hintText: 'Enter message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
