import 'dart:async';

import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<void> _connectFuture;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectFuture = _connect();
  }

  Future<void> _connect() async {
    try {
      await widget.chatService.connect();
      setState(() {
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
      setState(() {}); // Обновить UI после очистки поля ввода
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _connectFuture,
      builder: (context, snapshot) {
        if (_error != null) {
          return Center(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Expanded(
              child: _MessagesList(chatService: widget.chatService),
            ),
            _MessageInput(
              controller: _controller,
              onSend: _sendMessage,
            ),
          ],
        );
      },
    );
  }
}

class _MessagesList extends StatefulWidget {
  final ChatService chatService;

  const _MessagesList({Key? key, required this.chatService}) : super(key: key);

  @override
  State<_MessagesList> createState() => _MessagesListState();
}

class _MessagesListState extends State<_MessagesList> {
  final List<String> _messages = [];
  late final StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.chatService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
      });
    }, onError: (e) {
      // Игнорируем ошибки для простоты
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_messages[index]),
        );
      },
    );
  }
}

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInput({
    Key? key,
    required this.controller,
    required this.onSend,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding:
            const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter message',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
