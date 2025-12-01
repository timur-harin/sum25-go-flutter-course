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

  late TextEditingController _textController;
  late Future<void> _connectionFuture;
  late StreamSubscription<String> _subscription;
  final List<String> _messages = [];
  String? _error;


  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();

    _connectionFuture = widget.chatService.connect().catchError((e) {
      setState(() {
        _error = e.toString();
      });
    });

    _subscription = widget.chatService.messageStream.listen(
      (message) {
        setState(() {
          _messages.add(message);
        });
      },
      onError: (e) {
        setState(() {
          _error = e.toString();
        });
      },
    );
  }

  @override
  void dispose() {

    _textController.dispose();
    _subscription.cancel();

    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _error = null; // Clear previous error
    });

    try {
      await widget.chatService.sendMessage(text);
      _textController.clear();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: FutureBuilder<void>(
        future: _connectionFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (_error != null) {
            return Center(
              child: Text(
                'Connection error: $_error',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_messages[index]),
                    );
                  },
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    'Connection error: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: const InputDecoration(
                          hintText: 'Enter message',
                        ),
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
          );
        },
      ),
    );
  }
}
