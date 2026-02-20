import 'package:flutter/material.dart';
import 'chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _inputController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;
  StreamSubscription<ChatMessage>? _subscription;

  @override
  void initState() {
    super.initState();
    _chatService.startMocking();
    _subscription = _chatService.messageStream.listen(
          (msg) {
        setState(() {
          _messages.insert(0, msg);
        });
      },
      onError: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stream error: \$err')),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _chatService.dispose();
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final msg = ChatMessage(sender: 'You', content: text);

    try {
      await _chatService.sendMessage(msg);
      _inputController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: \$e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No messages yet.'))
                : ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                return ListTile(
                  title: Text(m.sender),
                  subtitle: Text(m.content),
                  trailing: Text(
                    TimeOfDay.fromDateTime(m.timestamp)
                        .format(context),
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _handleSend(),
                    decoration:
                    const InputDecoration(hintText: 'Type a message'),
                  ),
                ),
                const SizedBox(width: 8),
                _isSending
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _handleSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}