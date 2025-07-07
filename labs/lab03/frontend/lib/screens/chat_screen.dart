import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../main.dart'; // Предполагается, что ChatProvider определен здесь

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Загружаем сообщения при инициализации
    Provider.of<ChatProvider>(context, listen: false).loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);

    // Проверка валидации и установка ошибки через ChatProvider


    chatProvider.clearError();

    try {
      final request = CreateMessageRequest(username: username, content: content);
      await chatProvider.createMessage(request);
      _messageController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } catch (e) {
      // Ошибки обрабатываются в ChatProvider
    }
  }

  Future<void> _editMessage(Message message) async {
    final TextEditingController editController =
        TextEditingController(text: message.content);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Message Content',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, editController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      final request = UpdateMessageRequest(content: result);
      await Provider.of<ChatProvider>(context, listen: false)
          .updateMessage(message.id, request);
    } catch (e) {
      // Ошибки обрабатываются в ChatProvider
    }

    editController.dispose();
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
    );

    if (confirmed != true) return;

    try {
      await Provider.of<ChatProvider>(context, listen: false)
          .deleteMessage(message.id);
    } catch (e) {
      // Ошибки обрабатываются в ChatProvider
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    final chatProvider = Provider.of<ChatProvider>(context, listen: false);
    try {
      final status = await chatProvider.getHTTPStatus(statusCode);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(status.description),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                width: 100,
                child: Image.network(
                  status.imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) => const Text(
                    'Failed to load HTTP cat image',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get HTTP status: $e')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
        ),
      ),
      title: Text(
        '${message.username} • ${message.timestamp.toLocal().toString().substring(0, 16)}',
      ),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            _editMessage(message);
          } else if (value == 'delete') {
            _deleteMessage(message);
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'edit', child: Text('Edit')),
          const PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
      onTap: () {
        final randomStatusCodes = [200, 404, 500];
        final randomStatus =
            randomStatusCodes[DateTime.now().microsecond % randomStatusCodes.length];
        _showHTTPStatus(randomStatus);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Enter your username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Enter your message',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _sendMessage,
                  child: const Text('Send'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(200),
                  child: const Text('200 OK'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(404),
                  child: const Text('404 Not Found'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showHTTPStatus(500),
                  child: const Text('500 Error'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String? error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            error ?? 'An error occurred',
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Provider.of<ChatProvider>(context, listen: false).loadMessages(),
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

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('REST API Chat'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: chatProvider.loadMessages,
              ),
            ],
          ),
          body: chatProvider.isLoading
              ? _buildLoadingWidget()
              : chatProvider.error != null
                  ? _buildErrorWidget(chatProvider.error)
                  : chatProvider.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text('No messages yet', style: TextStyle(fontSize: 18)),
                              SizedBox(height: 8),
                              Text('Send your first message to get started!',
                                  style: TextStyle(fontSize: 14)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: chatProvider.messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageTile(chatProvider.messages[index]),
                        ),
          bottomSheet: _buildMessageInput(),
          floatingActionButton: FloatingActionButton(
            onPressed: chatProvider.loadMessages,
            child: const Icon(Icons.refresh),
          ),
        );
      },
    );
  }
}

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context) {
    final randomStatusCodes = [200, 201, 400, 404, 500];
    final randomStatus =
        randomStatusCodes[DateTime.now().microsecond % randomStatusCodes.length];
    _ChatScreenState()._showHTTPStatus(randomStatus);
  }

  static void showStatusPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select HTTP Status'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final code in [100, 200, 201, 400, 401, 403, 404, 418, 500, 503])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _ChatScreenState()._showHTTPStatus(code);
                    },
                    child: Text('HTTP $code'),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}