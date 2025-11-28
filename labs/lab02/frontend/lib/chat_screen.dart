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
  final TextEditingController _textController = TextEditingController();
  // TODO: Add state for messages, loading, and error
  final List<String> _messages = [];
  bool _isLoading = true;
  String? _error;
  // TODO: Subscribe to chatService.messageStream
  StreamSubscription<String>? _messageSubscription;
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _connectToChatService();
  }

  Future<void> _connectToChatService() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await widget.chatService.connect();
      _messageSubscription = widget.chatService.messageStream.listen(
            (message) {
          setState(() {
            _messages.add(message);
          });
        },
        onError: (error) {
          setState(() {
            _error = 'Stream error: $error';
          });
        },
        onDone: () {
          // No explicit action needed for stream done in this simple case
        },
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Connection error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _textController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    if (_textController.text.isEmpty) {
      return;
    }
    final message = _textController.text;
    _textController.clear();
    try {
      await widget.chatService.sendMessage(message);
    } catch (e) {
      setState(() {
        _error = 'Failed to send message: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      body: Column(
        children: [
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(
                  'Error: $_error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                reverse: true, // Show latest messages at the bottom
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final reversedIndex = _messages.length - 1 - index;
                  return Align(
                    alignment: Alignment.centerLeft, // Simulate incoming messages for now
                    child: Card(
                      color: Colors.blue[100],
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_messages[reversedIndex]),
                      ),
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Enter message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(), // Send on Enter
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