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
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  StreamSubscription<String>? _subscription;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initChatConnection();
  }

  void _initChatConnection() async {
    try {
      await widget.chatService.connect();
      _subscription = widget.chatService.messageStream.listen((message) {
        setState(() => _messages.add(message));
      });
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = 'Connection error';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    try {
      _messageController.clear();
      await widget.chatService.sendMessage(text);
    } catch (e) {
      // Failure is handled by stream error
    }
  }

  @override
  Widget build(BuildContext context) {
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
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_messages.reversed.toList()[index]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
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