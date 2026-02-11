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
  // TextEditingController for input
  final TextEditingController _messageController = TextEditingController();
  final List<String> _messages = [];
  StreamSubscription<String>? _messageSubscription;

  // State for loading
  bool _isLoading = true;
  
  // State for error
  String? _error;

  @override
  void initState() {
    super.initState();
    _initChatConnection();
  }

  Future<void> _initChatConnection() async {
    try {
      await widget.chatService.connect();
      // Subscribtion to chatService.messageStream
      _messageSubscription = widget.chatService.messageStream.listen(
        (message) {
          setState(() => _messages.add(message));
        },
        onError: (error) {
          setState(() => _error = 'Error while receiving message: $error');
        }
      );
      
      setState(() {
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Connection error: $e';
      });
    }
  }

  @override
  void dispose() {
    // Disposing the controllers and subscriptions
    _messageController.dispose();
    _messageSubscription?.cancel();
    super.dispose();
  }
  
  // Simulation of chat logic
  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;
    
    final message = _messageController.text;
    setState(() => _messageController.clear());
    
    try {
      await widget.chatService.sendMessage(message);
    } catch (e) {
      setState(() => _error = 'Sending error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot send message: $e')),
      );
    }
  }

// UI for sending and displaying messages
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
            itemCount: _messages.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_messages[index]),
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
                    hintText: 'Enter message...',
                    border: OutlineInputBorder(),
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
        ),
      ],
    );
  }
}
