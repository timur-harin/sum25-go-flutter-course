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
  final TextEditingController _textController = TextEditingController();

  final List<String> _messages = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<String>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().catchError((e) {
      setState(() {
        _error = 'Failed to connect';
      });
    });
    _messageSubscription = widget.chatService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.chatService.sendMessage(message);
      _textController.clear();
    } catch (e) {
      setState(() {
        _error = 'Failed to send message';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Center(
          child: Text(
            'Connection error: $_error!',
            style: const TextStyle(color: Colors.red, fontSize: 16.0),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Text(
                          _messages[index],
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      ),
                    );
                  },
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.0),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
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
