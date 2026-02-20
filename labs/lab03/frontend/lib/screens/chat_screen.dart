import 'dart:math';
import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ApiService _apiService = ApiService();
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _messages = await _apiService.getMessages();
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    if (username.isEmpty || content.isEmpty) return;
    final req = CreateMessageRequest(username: username, content: content);
    final validation = req.validate();
    if (validation != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validation)));
      return;
    }
    try {
      final msg = await _apiService.createMessage(req);
      setState(() => _messages.add(msg));
      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text('Save')),
        ],
      ),
    );
    if (result == null) return;
    final req = UpdateMessageRequest(content: result);
    final validation = req.validate();
    if (validation != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(validation)));
      return;
    }
    try {
      final updated = await _apiService.updateMessage(message.id, req);
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == message.id);
        _messages[idx] = updated;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete Message?'),
        content: Text('You want to delete this message?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text('No')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), child: Text('Yes')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await _apiService.deleteMessage(message.id);
      setState(() => _messages.removeWhere((m) => m.id == message.id));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  //hehe koty
  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final info = await _apiService.getHTTPStatus(statusCode);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('${info.statusCode} ${info.description}'),
          content: Image.network(info.imageUrl),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: Text('Close'))
          ],
        ),
      );
    } catch (_) {}
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0].toUpperCase())),
      title: Text('${message.username} • ${message.timestamp.toLocal()}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (val) {
          if (val == 'edit') _editMessage(message);
          if (val == 'delete') _deleteMessage(message);
        },
        itemBuilder: (_) => [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () => _showHTTPStatus([200, 404, 500][Random().nextInt(3)]),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: InputDecoration(labelText: 'Username'),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(labelText: 'Message'),
                ),
              ),
              IconButton(onPressed: _sendMessage, icon: Icon(Icons.send)),
              PopupMenuButton<int>(
                icon: Icon(Icons.info_outline),
                onSelected: _showHTTPStatus,
                itemBuilder: (_) => [100, 200, 201, 400, 404, 418, 500, 503]
                    .map((c) =>
                        PopupMenuItem(value: c, child: Text(c.toString())))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO: Implement ChatScreen'),
      ),
      body: Center(
        child: Text('TODO: Implement chat functionality'),
      ),
    );
  }
}
