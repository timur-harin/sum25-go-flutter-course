import 'dart:async';
import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

/// ChatScreen displays the chat UI with real-time messages
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late final StreamSubscription<String> _subscription;
  final List<String> _messages = [];
  bool _loading = true;
  String? _error;

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
    _subscription = widget.chatService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    }, onError: (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    widget.chatService.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text;
    widget.chatService.sendMessage(text).catchError((e) {
      setState(() {
        _error = e.toString();
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
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
                        itemBuilder: (context, index) {
                          return ListTile(title: Text(_messages[index]));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('messageField'),
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Type a message',
                              ),
                            ),
                          ),
                          IconButton(
                            key: const Key('sendButton'),
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
