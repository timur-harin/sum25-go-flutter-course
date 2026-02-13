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
  bool _loading = true;
  String? _error;
  StreamSubscription<String>? _sub;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().then((_) {
      setState(() {
        _loading = false;
      });
    }).catchError((e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
    _sub = widget.chatService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub?.cancel();
    widget.chatService.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await widget.chatService.sendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Connection error: $_error'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, idx) => ListTile(
                          title: Text(_messages[idx]),
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
                ),
    );
  }
}
