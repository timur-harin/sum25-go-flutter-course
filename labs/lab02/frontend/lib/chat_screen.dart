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
  final _controller = TextEditingController();
  List<String> messages = [];
  bool loading = true;
  String error = "";
  StreamSubscription<String>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    widget.chatService.connect().then((_) {
      setState(() {
        loading = false;
        error = "";
      });

      _messageSubscription = widget.chatService.messageStream.listen(
              (msg) {
            setState(() {
              messages = List.from(messages)..add(msg);
            });
          },
          onError: (err) {
            setState(() {
              error = 'Error receiving message: $err';
            });
          }
      );
    }).catchError((err) {
      setState(() {
        loading = false;
        error = 'Connection error';
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
    } catch (err) {
      setState(() {
        error = err.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(child: Text(error));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(messages[index]),
              ),
            ),
          ),
          Container(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}