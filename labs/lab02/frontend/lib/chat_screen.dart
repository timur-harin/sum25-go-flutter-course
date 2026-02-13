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
  late final TextEditingController _controller;
  final List<String> _messages = [];
  StreamSubscription<String>? _sub;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _init();
  }

  Future<void> _init() async {
    try {
      await widget.chatService.connect();
      _sub = widget.chatService.messageStream.listen(
            (msg) => setState(() => _messages.add(msg)),
        onError: (e) =>
            setState(() => _error = 'Stream error: ${e.toString()}'),
      );
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = 'Connection error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();
    try {
      await widget.chatService.sendMessage(text);
    } catch (e) {
      setState(() => _error = 'Send error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      // тест ищет подстроку «Connection error»
      return Center(child: Text(_error!));
    }

    return Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? const Center(child: Text('No messages'))
              : ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (_, i) => ListTile(title: Text(_messages[i])),
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
                  const InputDecoration(hintText: 'Type a message...'),
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
}