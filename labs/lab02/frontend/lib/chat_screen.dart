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
  // Text controller for user input
  final TextEditingController _controller = TextEditingController();

  // State variables
  List<String> _messages = [];
  bool _isLoading = true;
  String? _error;

  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();
    // Connect to chat service and set up listeners
    widget.chatService.connect().then((_) {
      setState(() {
        _isLoading = false;
      });
      _subscription = widget.chatService.messageStream.listen((msg) {
        setState(() {
          _messages.add(msg);
        });
      });
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _error = 'Connection error: ${e.toString()}';
      });
    });
  }

@override
void dispose() {
  _subscription?.cancel();
  _controller.dispose();
  super.dispose();
}


void _sendMessage() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;
  try {
    await widget.chatService.sendMessage(text);
    _controller.clear();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Send error: ${e.toString()}')),
    );
  }
}



  @override
  Widget build(BuildContext context) {
    // Build chat UI with loading, error, and message list
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
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
        Padding(
          padding: const EdgeInsets.all(8.0),
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
    );
  }
}
