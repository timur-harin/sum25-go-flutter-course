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
  // TODO: Add TextEditingController for input
  TextEditingController _textEditingController = TextEditingController();
  // TODO: Add state for messages, loading, and error
  final List<String> _messages = [];
  StreamSubscription<String>? _subscription;
  bool _isLoading = false;
  String? _error;
  // TODO: Subscribe to chatService.messageStream
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _connectAndListen();

  }

  Future<void> _connectAndListen() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.chatService.connect();

      _subscription = widget.chatService.messageStream.listen(
        (message) {
          setState(() {
            _messages.add(message);
          });
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
          });
        },
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    if (_subscription != null) {
      _subscription!.cancel();
    }
    _textEditingController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final text = _textEditingController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.chatService.sendMessage(text);
      _textEditingController.clear();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (_error != null)
            Container(
              child: Row(
                children: [
                  const Icon(Icons.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Connection error: $_error'
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _error = null;
                      });
                    },
                  ),
                ],
              ),
            ),
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
          if (_isLoading) const LinearProgressIndicator(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Enter your message',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
