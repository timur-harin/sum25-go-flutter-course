import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    _messageController.dispose();
    _usernameController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final messages = await _apiService.getMessages();
      setState(() {
        _messages = messages;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    if (username.isEmpty || content.isEmpty) {
      return;
    }
    final request = CreateMessageRequest(username: username, content: content);
    try {
      final response = await _apiService.createMessage(request);
      setState(() {
        _messages.insert(0, response);
        _messageController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final editController = TextEditingController(text: message.content);
    final editing = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(
          controller: editController,
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('cancel')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('save')),
        ],
      ),
    );
    if (editing == true) {
      final newContent = editController.text.trim();
      if (newContent.isEmpty) {
        return;
      }
      final request = UpdateMessageRequest(content: newContent);
      try {
        final response = await _apiService.updateMessage(message.id, request);
        setState(() {
          final index =
          _messages.indexWhere((element) => element.id == message.id);
          if (index != -1) {
            _messages[index] = response;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message edited')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Are you sure you want to delete the message?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('no')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('yes')),
        ],
      ),
    );
    if (confirmation == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Message deleted')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final response = await _apiService.getHTTPStatus(statusCode);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${response.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(response.description),
              const SizedBox(height: 10),
              Image.network(
                'http://localhost:8080/api/cat/${response.statusCode}',
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return _buildLoadingWidget();
                },
                errorBuilder: (context, error, stack) {
                  return _buildErrorWidget();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username.isNotEmpty
            ? message.username[0].toUpperCase()
            : '?'),
      ),
      title: Text('${message.username} ${message.timestamp}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
        onSelected: (value) {
          if (value == 'edit') {
            _editMessage(message);
          } else if (value == 'delete') {
            _deleteMessage(message);
          }
        },
      ),
      onTap: () {
        final statusCodes = [200, 404, 500];
        statusCodes.shuffle();
        _showHTTPStatus(statusCodes.first);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      color: Colors.blueAccent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: 'Enter your username',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              hintText: 'Enter your message',
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: () => _showHTTPStatus(200),
                  child: const Text('200 OK')),
              const SizedBox(width: 4),
              ElevatedButton(
                  onPressed: () => _showHTTPStatus(404),
                  child: const Text('404 Not Found')),
              const SizedBox(width: 4),
              ElevatedButton(
                  onPressed: () => _showHTTPStatus(500),
                  child: const Text('500 Error')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('retry'),
          ),
        ],
      ),
    );// Placeholder
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );// Placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            onPressed: _loadMessages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _error != null
          ? _buildErrorWidget()
          : ListView.builder(
        itemCount: _messages.length,
        itemBuilder: (context, index) =>
            _buildMessageTile(_messages[index]),
      ),
      bottomSheet: _buildMessageInput(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [200, 201, 400, 404, 500];
    codes.shuffle();
    final state = context.findAncestorStateOfType<_ChatScreenState>();
    if (state != null) {
      state._showHTTPStatus(codes.first);
    }
  }


  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Choose HTTP code'),
        children: [100, 200, 201, 400, 401, 403, 404, 418, 500, 503]
            .map(
              (code) => SimpleDialogOption(
            child: Text('$code'),
            onPressed: () {
              Navigator.of(context).pop();
              final state = context.findAncestorStateOfType<_ChatScreenState>();
              if (state != null) {
                state._showHTTPStatus(code);
              }
            },
          ),
        )
            .toList(),
      ),
    );
  }
}
