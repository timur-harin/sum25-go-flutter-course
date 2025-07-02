import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'package:flutter/material.dart';
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
  late StreamSubscription<String> _messageSub;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Subscribe to chat service stream
    _messageSub = widget.chatService.messageStream.listen((msg) {
      setState(() {
        _messages.add(msg);
        _loading = false;
      });
    }, onError: (err) {
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    });
    // Initialize connection
    widget.chatService.connect().then((_) {
      if (mounted) setState(() => _loading = false);
          }).catchError((err) {
      setState(() {
        _error = err.toString();
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _messageSub.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _loading = true;
    });
    try {
      await widget.chatService.sendMessage(text);
      _textController.clear();
    } catch (err) {
      setState(() {
        _error = err.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _loading && _messages.isEmpty
                ? const Center(child: Text('Loading...'))
                : _error != null
                ? Center(child: Text('Connection error: ${_error!}'))
                : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_messages[index]),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
