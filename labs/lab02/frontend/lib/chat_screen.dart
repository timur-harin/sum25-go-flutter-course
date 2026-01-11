import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'dart:async';

/// ChatScreen displays the chat UI, message list, and input field.
class ChatScreen extends StatefulWidget {
  final ChatService chatService;
  const ChatScreen({super.key, required this.chatService});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<String> _messages = [];

  // FIX 1: Make the subscription nullable.
  StreamSubscription<String>? _messageSubscription;

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _connectToChat();
  }

  Future<void> _connectToChat() async {
    try {
      await widget.chatService.connect();
      _messageSubscription = widget.chatService.messageStream.listen((message) {
        if (!mounted) return;
        setState(() {
          _messages.add(message);
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Connection error: Could not connect.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    // FIX 2: Only cancel the subscription if it's not null.
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _textController.text;
    if (text.isNotEmpty) {
      try {
        await widget.chatService.sendMessage(text);
        _textController.clear();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to send message: ${e.toString()}'),
                backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildMessageList()),
        const Divider(height: 1),
        _buildTextInput(),
      ],
    );
  }

  Widget _buildMessageList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      ));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final isSystemMessage = message.startsWith('System:');
        return Align(
          alignment:
              isSystemMessage ? Alignment.center : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            padding:
                const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isSystemMessage
                  ? Colors.grey.shade300
                  : Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              message,
              style: TextStyle(
                  fontStyle: isSystemMessage ? FontStyle.italic : null),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Enter a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
}