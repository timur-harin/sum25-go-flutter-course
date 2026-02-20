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
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
    _loadMessages();
  }

  @override
  void dispose() {
    _apiService.dispose();
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
      final messages = await _apiService.getMessages();
      setState(() => _messages = messages);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();
    final request = CreateMessageRequest(username: username, content: content);

    final validationError = request.validate();
    if (validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validationError)),
      );
      return;
    }

    try {
      final newMessage = await _apiService.createMessage(request);
      setState(() => _messages.add(newMessage));
      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final contentController = TextEditingController(text: message.content);

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit message'),
        content: TextField(controller: contentController),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, contentController.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent != null && newContent != message.content) {
      try {
        final request = UpdateMessageRequest(content: newContent);
        final updatedMessage =
            await _apiService.updateMessage(message.id, request);

        if (!mounted) return;

        setState(() {
          _messages = _messages
              .map((m) => m.id == message.id ? updatedMessage : m)
              .toList();
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update message: $e')),
        );
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete message?'),
        content: Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _apiService.deleteMessage(message.id);
        setState(() => _messages.removeWhere((m) => m.id == message.id));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: $e')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      final status = await _apiService.getHTTPStatus(statusCode);

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (status.imageUrl.isNotEmpty)
                  Image.network(
                    status.imageUrl,
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error_outline, size: 100);
                    },
                  ),
                const SizedBox(height: 16),
                Text(status.description),
              ],
            ),
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
        SnackBar(
          content: Text('Failed to get status: ${e.toString()}'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(child: Text(message.username[0])),
      title: Row(
        children: [
          Text(message.username),
          SizedBox(width: 8),
          Text(
            message.timestamp.toLocal().toString().split('.')[0],
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Text(message.content),
      trailing: PopupMenuButton(
        itemBuilder: (context) => [
          PopupMenuItem(child: Text('Edit'), value: 'edit'),
          PopupMenuItem(child: Text('Delete'), value: 'delete'),
        ],
        onSelected: (value) {
          if (value == 'edit') _editMessage(message);
          if (value == 'delete') _deleteMessage(message);
        },
      ),
      onTap: () {
        final statusCodes = [200, 404, 500];
        final randomCode =
            statusCodes[DateTime.now().millisecond % statusCodes.length];
        _showHTTPStatus(randomCode);
      },
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Enter your username'),
          ),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Enter your message'),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
              const SizedBox(width: 8),
              ..._buildStatusButtons(),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildStatusButtons() {
    return [
      TextButton(
        onPressed: () => _showHTTPStatus(200),
        child: const Text('200 OK'),
      ),
      TextButton(
        onPressed: () => _showHTTPStatus(404),
        child: const Text('404 Not Found'),
      ),
      TextButton(
        onPressed: () => _showHTTPStatus(500),
        child: const Text('500 Error'),
      ),
    ];
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 64),
          Text(_error ?? 'Unknown error', style: TextStyle(color: Colors.red)),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMessages,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Center(child: CircularProgressIndicator());
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
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : _messages.isEmpty
                      ? _buildEmptyWidget()
                      : ListView.builder(
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageTile(_messages[index]),
                        ),
        ),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 64),
          const SizedBox(height: 16),
          const Text('No messages yet'),
          const Text('Send your first message to get started!'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadMessages,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final statusCodes = [200, 201, 400, 404, 500];
    final randomCode =
        statusCodes[DateTime.now().millisecond % statusCodes.length];

    final state = context.findAncestorStateOfType<_ChatScreenState>();
    if (state != null) {
      state._showHTTPStatus(randomCode);
    }
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    final statusCodes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select HTTP Status'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: statusCodes
              .map((code) => TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      final state =
                          context.findAncestorStateOfType<_ChatScreenState>();
                      if (state != null) {
                        state._showHTTPStatus(code);
                      }
                    },
                    child: Text('$code'),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
