import 'package:flutter/material.dart';
import 'chat_service.dart';

// ChatScreen displays the chat UI
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({Key? key, required this.chatService}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  // TODO: Add loading/error state if needed

  @override
  void initState() {
    super.initState();
    // TODO: Connect to chat service
  }

  @override
  void dispose() {
    _controller.dispose();
    // TODO: Dispose chat service if needed
    super.dispose();
  }

  void _sendMessage() {
    // TODO: Send message using chatService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<String>(
              stream: widget.chatService.messageStream,
              builder: (context, snapshot) {
                // TODO: Display messages, loading, and error states
                return ListView(
                  children: [
                    // TODO: Build message widgets from snapshot.data
                  ],
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
                    decoration:
                        const InputDecoration(hintText: 'Type a message'),
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
