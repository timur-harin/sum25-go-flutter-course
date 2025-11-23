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
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  StreamSubscription<String>? _subscription;
  String? _error;

  @override
  void initState() {
    super.initState();
    _subscription = widget.chatService.messageStream.listen(
      (msg) {
        setState(() {
          _messages.add(msg);
        });
      },
      onError: (_) {
        setState(() {
          _error = 'Connection error';
        });
      },
    );
    widget.chatService.connect().catchError((_) {
      setState(() {
        _error = 'Connection error';
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text;
    if (text.isEmpty) return;
    _controller.clear();
    widget.chatService.sendMessage(text).catchError((_) {
      setState(() {
        _error = 'Connection error';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _error != null
          ? Center(child: Text(_error!))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) =>
                        ListTile(title: Text(_messages[index])),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(controller: _controller),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
