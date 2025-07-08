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
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool _loading = false;
  String? _error;
  StreamSubscription<String>? _subscription;

  @override
  void initState() {
    super.initState();

    setState(() {
      _loading = true;
      _error = null;
    });

    _connect().then((_) {
      _subscription = widget.chatService.messageStream.listen(
        (msg) {
          setState(() {
            _messages.add(msg);
          });
        },
        onError: (e) {
          setState(() {
            _error = e.toString();
          });
        },
      );
    });
  }

  Future<void> _connect() async {
    try {
      await widget.chatService.connect();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    _controller.clear();
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await widget.chatService.sendMessage(text);
      _controller.clear();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Build chat UI with loading, error, and message list
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Center(
        child: Stack(
          children: [
            Column(
              children: [
                if (_error != null)
                  Container(
                      color: Colors.red,
                      padding: const EdgeInsets.all(8),
                      width: double.infinity,
                      child: Text('Connection error: $_error!',
                          style: const TextStyle(color: Colors.red))),
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (content, index) {
                          return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.greenAccent,
                                ),
                                child: Text(
                                  _messages[index],
                                  style: TextStyle(fontSize: 20),
                                ),
                              ));
                        },
                      ),
                      if (_loading)
                        const Center(
                            child: CircularProgressIndicator(
                          color: Colors.greenAccent,
                        )),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.greenAccent,
                  ),
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8.0),
                          border: InputBorder.none,
                        ),
                      )),
                      IconButton(
                          iconSize: MediaQuery.of(context).size.width * 0.017,
                          color: const Color.fromARGB(255, 5, 20, 156),
                          onPressed: _loading ? null : _sendMessage,
                          icon: Icon(Icons.send))
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
