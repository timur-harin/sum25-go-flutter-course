import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late StreamSubscription<String> _subscription;
  List<String> _messages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().then((_) {
      setState(() {
        _isLoading = false;
      });
    }).catchError((error) {
      setState(() {
        _error = 'Connection error: ${error.toString()}';
        _isLoading = false;
      });
    });

    _subscription = widget.chatService.messageStream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    }, onError: (error) {
      setState(() {
        _error = 'Stream error: ${error.toString()}';
      });
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await widget.chatService.sendMessage(text);
      setState(() {
        _controller.clear();
      });
    } catch (e) {
      setState(() {
        _error = 'Send error: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          if (_isLoading) ...[
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
          ] else if (_error != null) ...[
            Expanded(
              child: Center(child: Text(_error!)),
            ),
          ] else ...[
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_messages[index]),
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
                      controller: _controller,
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
        ],
      ),
    );
  }
}
