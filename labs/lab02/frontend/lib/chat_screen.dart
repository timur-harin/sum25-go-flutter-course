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
  final _inputController = TextEditingController();
  List<String> messages = [];
  bool loading = false;
  String? error;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    loading = true;
    widget.chatService.connect().then((_) {
      setState(() {
        loading = false;
      });
      _subscription = widget.chatService.messageStream.listen((msg) {
        setState(() {
          messages = List.from(messages)..add(msg);
        });
      }, onError: (err) {
        setState(() {
          error = err.toString();
        });
      });
    }).catchError((err) {
      setState(() {
        loading = false;
        error = err.toString();
      });
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      loading = true;
      error = null;
    });
    try {
      await widget.chatService.sendMessage(text);
      setState(() {
        _inputController.clear();
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (loading) const LinearProgressIndicator(),
          if (error != null)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(child: Text('Connection error', style: const TextStyle(color: Colors.red))),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        error = null;
                      });
                    },
                  )
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return ListTile(
                  title: Text(msg),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: loading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
