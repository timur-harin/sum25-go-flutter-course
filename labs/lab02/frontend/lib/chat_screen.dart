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
  final TextEditingController controller = TextEditingController();
  final List<String> messages = [];
  StreamSubscription<String>? subscription;
  String? error;


  @override
  void initState() {
    super.initState();
    _connect();
  }

  void _connect() async {
    try {
      await widget.chatService.connect();
      subscription = widget.chatService.messageStream.listen((message) {
        setState(() => messages.add(message));
      });
    } catch (e) {
      setState(() => error = 'Connection error: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    subscription?.cancel();
    controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (controller.text.isEmpty) return;
    try {
      await widget.chatService.sendMessage(controller.text);
      controller.clear();
    } catch (e) {
      setState(() => error = 'Send error: ${e.toString()}');
    }

  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: error != null
          ? Center(child: Text(error!))
          : Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? const Center(child: Text('No messages yet'))
                      : ListView.builder(
                          itemCount: messages.length,
                          itemBuilder: (context, index) => 
                              ListTile(title: Text(messages[index])),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
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
            ),
    );
  }
}