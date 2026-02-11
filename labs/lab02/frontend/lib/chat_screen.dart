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
  final TextEditingController _input = TextEditingController();
  final List<String> _messages = []; // Stores all messages
  bool _isLoading = false;
  String? _error;
  StreamSubscription<String>? _messageSubscription;

  @override
  void initState() {
    super.initState();
    _connectToChat();
  }

  void _connectToChat() async {
    setState(() => _isLoading = true);
    try {
      await widget.chatService.connect();
      // Listen to stream and add to messages list
      _messageSubscription = widget.chatService.messageStream.listen(
        (message) => setState(() => _messages.add(message)),
        onError: (error) => setState(() => _error = error.toString()),
      );
    } catch (e) {
      setState(() => _error = 'Connection error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_input.text.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      await widget.chatService.sendMessage(_input.text);
      _input.clear();
    } catch (e) {
      setState(() => _error = 'Send failed: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
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

              if (_isLoading && _messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (_error != null && _messages.isEmpty) {
                return Center(
                  child: RichText(
                    text : TextSpan(text : 'Error: $_error')
                  )
                );
              }
              
              return ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(_messages[index]),
                ),
              );
            },
          ),
        ),
        _buildInputArea(),
        if (_error != null) _buildErrorDisplay(),
      ],
    ),
  );
}

  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _input,
              decoration: const InputDecoration(hintText: 'Type a message'),
            ),
          ),
          IconButton(
            icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.send),
            onPressed: _isLoading ? null : _sendMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay() {
    return Container(
      color: Colors.red[100],
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(_error!)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }
}