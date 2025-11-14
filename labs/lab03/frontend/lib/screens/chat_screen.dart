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
  late final ApiService _apiService;
  List<Message> _messages = [];
  bool _isLoading = false;
  bool _isInitialLoad = true;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _apiService = Provider.of<ApiService>(context);
    // Убрали автоматическую загрузку сообщений
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _isInitialLoad = false; // Устанавливаем флаг, что начальная загрузка прошла
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username and message cannot be empty')),
      );
      return;
    }

    try {
      final newMessage = await _apiService.createMessage(
        CreateMessageRequest(username: username, content: content),
      );
      setState(() {
        _messages.add(newMessage);
        _messageController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${e.toString()}')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: message.content);
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(controller: controller),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newContent != null && newContent != message.content) {
      try {
        final updatedMessage = await _apiService.updateMessage(
          message.id,
          UpdateMessageRequest(content: newContent),
        );
        setState(() {
          _messages[_messages.indexWhere((m) => m.id == message.id)] =
              updatedMessage;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update message: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text('Are you sure you want to delete this message?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirmed) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() {
          _messages.removeWhere((m) => m.id == message.id);
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final statusInfo = await _apiService.getHTTPStatus(statusCode);
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(statusInfo.description),
              const SizedBox(height: 16),
              Image.network(
                'https://http.cat/$statusCode',
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const CircularProgressIndicator();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get HTTP status: ${e.toString()}')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username[0].toUpperCase()),
      ),
      title: Row(
        children: [
          Text(message.username),
          const Spacer(),
          Text(message.timestamp.toLocal().toString()),
        ],
      ),
      subtitle: Text(message.content),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: Text('Edit'),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: Text('Delete'),
          ),
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
        final randomCode = statusCodes[DateTime.now().millisecond % 3];
        _showHTTPStatus(randomCode);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const Spacer(),
              ...['200', '404', '500'].map((code) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => _showHTTPStatus(int.parse(code)),
                    child: Text(code),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildInitialPlaceholder() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'TODO: Chat messages will appear here',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: _isInitialLoad
          ? _buildInitialPlaceholder() // Показываем placeholder при первой загрузке
          : _isLoading
              ? _buildLoadingWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : _messages.isEmpty
                      ? _buildInitialPlaceholder() // Показываем placeholder если нет сообщений
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