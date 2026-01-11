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
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _loading = false;
  Exception? _error;
  late StreamSubscription<String> _subscription;

  // TODO: Add TextEditingController for input
  // TODO: Add state for messages, loading, and error
  // TODO: Subscribe to chatService.messageStream
  // TODO: Implement UI for sending and displaying messages
  // TODO: Simulate chat logic for tests (current implementation is a simulation)

  @override
  void initState() {
    super.initState();
    _subscription = widget.chatService.messageStream.listen(
      (message) {
        setState(() {
          _messages.add(message);
        });
      },
      onError: (error) {
        setState(() {
          _error = error;
        });
      },
    );
    // TODO: Connect to chat service and set up listeners
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and subscriptions
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.chatService.sendMessage(_controller.text);
      _controller.clear();
    } catch (e) {
      setState(() {
        _error = Exception("Failed to send message");
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
    // TODO: Send message using chatService
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
        appBar: AppBar(title: const Text('Chat')),
        body: Column(
          children: [
            StreamBuilder<String>(
              stream: widget.chatService.messageStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // If the snapshot has data, display the messages
                return ListView.builder(
                  itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                  itemBuilder: (context, index) {
                    return ListTile(title: Text(snapshot.data![index]));
                  },
                );
              },
            ),
            TextField(controller: _controller),
            IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send))
          ],
        ));
  }
}
