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
  late StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().then((_) {
      setState(() => _loading = false);
    }).catchError((e) {
      setState(() {
        _error = 'Connection error: ${e.toString()}';
        _loading = false;
      });
    });
    _subscription = widget.chatService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
    } catch (e) {
      setState(() {
        _error = 'Send error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text(_messages[index]));
            },
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
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
      ],
    );
  }
}
