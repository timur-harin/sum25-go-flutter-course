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
  // TODO: Add state for messages, loading, and error
  // TODO: Subscribe to chatService.messageStream
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service and set up listeners
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    super.dispose();
  }

  void _sendMessage() async {
    // TODO: Send message using chatService
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: const Center(child: Text('TODO: Implement chat UI')),
    );
  }
}
