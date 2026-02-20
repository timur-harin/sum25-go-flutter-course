import 'package:flutter/material.dart';
import 'dart:async';

import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({Key? key, required this.chatService}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final List<String> _messages = [];

  late bool _loading;
  String? _error;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    _loading = true;

    widget.chatService
        .connect()
        .then((_) {
      _subscription =
          widget.chatService.messageStream.listen((incoming) => setState(() {
            _messages.add(incoming);
          }));
      setState(() => _loading = false);
    })
        .catchError((e) => setState(() {
      _loading = false;
      _error = e.toString();
    }));
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      await widget.chatService.sendMessage(text);
      _textController.clear();
    } catch (e) {
      setState(() => _error = 'Send error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(child: Text('Connection error: $_error'));
    } else {
      body = Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: const Key('messageList'),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, i) =>
                  ListTile(title: Text(_messages[i])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('inputField'),
                    controller: _textController,
                    decoration:
                    const InputDecoration(hintText: 'Enter message'),
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
      );
    }


    return body;
  }
}
