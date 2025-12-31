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
  final TextEditingController _controller = TextEditingController();
  // TODO: Add state for messages, loading, and error
  List<String> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;
  // TODO: Subscribe to chatService.messageStream
  StreamSubscription<String>? _subscription;
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
    _isLoading = true;
    widget.chatService.connect().then((_) {
      setState(() {
        _isLoading = false;
      });

      _subscription = widget.chatService.messageStream.listen((message) {
        setState(() {
          _messages.add(message);
        });
      }, onError: (error) {
        setState(() {
          _errorMessage = 'Connection error';
        });
      });
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Connection error';
      });
    });
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _controller.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.chatService.sendMessage(text);
      setState(() {
        _controller.clear();
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Connection error';
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
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(_messages[index]));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter message',
                    ),
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
