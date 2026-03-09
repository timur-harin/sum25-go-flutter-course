import 'dart:async';

import 'package:flutter/material.dart';
import 'chat_service.dart';

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
  final _textController = TextEditingController();
  List<String> messages = [];
  bool _connecting = true;
  String? _connectionError;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().then((_) {
      setState(() => _connecting = false);
    }).catchError((error) {
      setState(() {
        _connecting = false;
        _connectionError = 'Connection error: ${error.toString()}';
      });
    });
    // TODO: Connect to chat service and set up listeners
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _textController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage(String msg) async {
    // TODO: Send message using chatService
    await widget.chatService.sendMessage(msg);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: _connecting ?
      CircularProgressIndicator() : _connectionError != null ?
      Center(child: Text(_connectionError!)) :
      StreamBuilder(
        stream: widget.chatService.messageStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData && messages.isEmpty) {
            return const Center(child: Text('No messages yet'));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Connection error'));
          }
          if (snapshot.hasData) {
            messages.add(snapshot.data!);
          }
          return ListView.separated(
            itemBuilder: (context, index) => Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(messages[index], style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            separatorBuilder: (context, index) => SizedBox(height: 8),
            itemCount: messages.length,
          );
        }
      ),
      bottomSheet: Row(
        children: [
          Expanded(
            child: TextField(controller: _textController)
          ),
          IconButton(
            onPressed: () {_sendMessage(_textController.text);},
            icon: Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
