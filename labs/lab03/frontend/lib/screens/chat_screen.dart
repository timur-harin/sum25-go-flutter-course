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
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
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
      setState(() => _messages = messages);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    final request = CreateMessageRequest(
      username: _usernameController.text,
      content: _messageController.text,
    );
    if (request.validate() != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(request.validate()!)));
      return;
    }
    try {
      final message = await _apiService.createMessage(request);
      setState(() => _messages.add(message));
      _messageController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    final updatedContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Message'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Save'),
          ),
        ],
      ),
    );
    if (updatedContent != null) {
      try {
        final updatedMessage = await _apiService.updateMessage(
          message.id,
          UpdateMessageRequest(content: updatedContent),
        );
        setState(() {
          _messages[_messages.indexWhere((m) => m.id == message.id)] =
              updatedMessage;
        });
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteMessage(Message message) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Message?'),
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
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP $statusCode'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                'https://http.cat/$statusCode.jpg',
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : CircularProgressIndicator(),
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.error, color: Colors.red),
              ),
              SizedBox(height: 16),
              Text(
                _getHTTPStatusDescription(statusCode),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to load HTTP cat: $e')));
    }
  }

  String _getHTTPStatusDescription(int code) {
    switch (code) {
      case 200:
        return 'OK - The request succeeded';
      case 201:
        return 'Created - Resource was created';
      case 400:
        return 'Bad Request - Server cannot process request';
      case 404:
        return 'Not Found - Resource not found';
      case 500:
        return 'Internal Server Error - Unexpected server error';
      case 418:
        return "I'm a teapot - April Fool's joke status code";
      default:
        return 'HTTP Status Code: $code';
    }
  }

  Widget _buildMessageTile(Message message) => ListTile(
        leading: CircleAvatar(
            child: Text(message.username.substring(0, 1).toUpperCase())),
        title: Text(
            '${message.username} • ${_formatTimestamp(message.timestamp)}'),
        subtitle: Text(message.content),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Text('Edit'),
              onTap: () =>
                  Future.delayed(Duration.zero, () => _editMessage(message)),
            ),
            PopupMenuItem(
              child: Text('Delete'),
              onTap: () =>
                  Future.delayed(Duration.zero, () => _deleteMessage(message)),
            ),
          ],
        ),
        onTap: () =>
            _showHTTPStatus([200, 404, 500][DateTime.now().millisecond % 3]),
      );

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
            SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text('HTTP Status:'),
                  SizedBox(width: 8),
                  ...['200', '404', '500', '418'].map((code) => Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(code),
                          onPressed: () => _showHTTPStatus(int.parse(code)),
                        ),
                      )),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildErrorWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 48),
            SizedBox(height: 16),
            Text(_error ?? 'Unknown error',
                style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMessages,
              child: Text('Retry'),
            ),
          ],
        ),
      );

  Widget _buildLoadingWidget() => Center(child: CircularProgressIndicator());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CHAAAAAAAAAAAAAAAAAT'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: Text('TODO: Chat messages will appear here'))
          : _isLoading
              ? _buildLoadingWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : _messages.isEmpty
                      ? Center(child: Text('No messages yet'))
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _messages.length,
                          itemBuilder: (context, i) =>
                              _buildMessageTile(_messages[i]),
                        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => HTTPStatusDemo.showRandomStatus(context, _apiService),
        child: Icon(Icons.pets),
        tooltip: 'Random HTTP Cat',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: _buildMessageInput(),
    );
  }
}

class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) {
    final codes = [200, 201, 400, 404, 418, 500];
    final randomCode = codes[DateTime.now().millisecond % codes.length];

    // Get the ChatScreen state using the context
    final chatScreenState = context.findAncestorStateOfType<_ChatScreenState>();
    if (chatScreenState != null) {
      chatScreenState._showHTTPStatus(randomCode);
    }
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context,
      builder: (context) {
        // Get the ChatScreen state using the context
        final chatScreenState =
            context.findAncestorStateOfType<_ChatScreenState>();

        return AlertDialog(
          title: Text('Select HTTP Status'),
          content: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [100, 200, 201, 400, 401, 403, 404, 418, 500, 503]
                  .map(
                    (code) => ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        chatScreenState?._showHTTPStatus(code);
                      },
                      child: Text('$code'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(60, 40),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
