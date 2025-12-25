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
  final TextEditingController _inputController = TextEditingController();
  final List<String> _chatHistory = [];
  bool _connecting = true;
  String? _connectionError;

  StreamSubscription<String>? _chatStreamSubscription;

  @override
  void initState() {
    super.initState();
    _initializeChatConnection();
  }

  Future<void> _initializeChatConnection() async {
    try {
      await widget.chatService.connect();
      _chatStreamSubscription = widget.chatService.messageStream.listen(
        (newMessage) => setState(() => _chatHistory.add(newMessage)),
        onError: (err) {
          if (_connectionError == null) {
            setState(() => _connectionError = 'Connection error');
          }
        },
      );
      setState(() => _connecting = false);
    } catch (e) {
      setState(() {
        _connectionError = 'Connection error';
        _connecting = false;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _chatStreamSubscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final message = _inputController.text.trim();
    if (message.isEmpty) return;

    _inputController.clear();
    try {
      await widget.chatService.sendMessage(message);
      setState(() => _chatHistory.add(message));
    } catch (e) {
      if (_connectionError == null) {
        setState(() => _connectionError = 'Message not delivered');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_connecting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_connectionError != null) {
      return Center(child: Text(_connectionError!));
    }
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _chatHistory.length,
            itemBuilder: (context, i) => Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_chatHistory[i]),
              ),
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
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
      ],
    );
  }
}