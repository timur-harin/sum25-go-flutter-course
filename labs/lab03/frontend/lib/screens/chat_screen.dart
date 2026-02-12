import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

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
    _apiService.dispose();
    super.dispose();
  }

  void _saveMessage(Message message) {
    _messageController.text = message.content;
    setState(() {});
  }

  Future<void> _loadMessages() async {
    _isLoading = true;
    _error = null;
    try {
      _messages = await _apiService.getMessages();
    }
    catch(e) {
      _error = "Error";
    }
    finally {
      _isLoading = false;
    }
    setState(() {});
  }

  Future<void> _sendMessage() async {
    String username = _usernameController.text;
    String content = _messageController.text;
    CreateMessageRequest createMessageRequest = CreateMessageRequest(username: username, content: content);
    try {
      Message message = await _apiService.createMessage(createMessageRequest);
      _messages.add(message);
      _messageController.clear();
    }
    catch(e) {}
    setState(() {});
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                _saveMessage(message);
                UpdateMessageRequest updateMessageRequest = UpdateMessageRequest(content: controller.text);
                Message newMessage = await _apiService.updateMessage(message.id, updateMessageRequest);
                int index = _messages.indexWhere((msg) => msg.id == message.id);
                if (index != -1) _messages[index] = newMessage;
                controller.dispose();
                Navigator.pop(context);
                setState(() {});
              },
              child: const Text("Save")
            )
          ],
        );
      }
    );
    setState(() {});
  }

  Future<void> _deleteMessage(Message message) async {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          content: const Text(
            "Are you sure?"
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _apiService.deleteMessage(message.id);
                int index = _messages.indexWhere((msg) => msg.id == message.id);
                if (index != -1) _messages.removeAt(index);
                setState(() {});
              },
              child: const Text("Yes")
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text("No")
            )
          ],
        );
      }
    );
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    final httpStatusResponse = await _apiService.getHTTPStatus(statusCode);
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          content: Column(children: [
            Text("HTTP Status: $statusCode"),
            Text(httpStatusResponse.description),
            Image.network(
              httpStatusResponse.imageUrl,
              loadingBuilder: (context, child, loadingProgress) => loadingProgress == null ? child: const CircularProgressIndicator(),
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.error_outline),
            )
          ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {});
              },
              child: const Text("Close")
            )
          ],
        );
      }
    );
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(message.username[0]),
      ),
      title: Text("${message.username} ${message.timestamp}"),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == "Edit") {
            _editMessage(message);
          }
          if (value == "Delete") {
            _deleteMessage(message);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: "Edit",
            child: Text("Edit")
          ),
          const PopupMenuItem<String>(
            value: "Delete",
            child: Text("Delete")
          )
        ]
      ),
      onTap: () async {
        final statusCodes = [200, 404, 500];
        Random random = Random();
        int randomStatusCode = statusCodes[random.nextInt(statusCodes.length)];
        await _showHTTPStatus(randomStatusCode);
      }
    ); // Placeholder
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Colors.blue
      ),
      child: Column(children: [
        TextField(
          controller: _usernameController,
          decoration: const InputDecoration(
            labelText: "Enter your username"
          ),
        ),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            labelText: "Enter your message"
          ),
        ),
        Row(children: [
          TextButton(
            onPressed: () async {
              await _showHTTPStatus(200);
            },
            child: const Text("200 OK")
          ),
          TextButton(
            onPressed: () async {
              await _showHTTPStatus(404);
            },
            child: const Text("404 Not Found")
          ),
          TextButton(
            onPressed: () async {
              await _showHTTPStatus(500);
            },
            child: const Text("500 Error")
          ),
          TextButton(
            onPressed: () => {
              _sendMessage(),
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Success"))
              )
            },
            child: const Text("Send")
          )
        ],
        )
      ],
      ),
    ); // Placeholder
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
          Text(
            _error!, style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          ElevatedButton(
            onPressed: _loadMessages,
            child: Text(
              "Retry",
              style: TextStyle(color: Theme.of(context).colorScheme.error)
            )
          )
        ]
      )
    ); // Placeholder
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: CircularProgressIndicator()
    ); // Placeholder
  }

  Widget _buildEmptyStateWidget() {
    return const Column(children: [
      Text('No messages yet'),
      SizedBox(height: 15),
      Text('Send your first message to get started!')
    ],);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: <Widget>[
          IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh))
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _loadMessages, child: const Icon(Icons.refresh)),
      body: _messages.isEmpty
        ? _buildEmptyStateWidget()
        : _error != null
        ? _buildErrorWidget()
        : _isLoading
        ? _buildEmptyStateWidget()
        : Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => _buildMessageTile(_messages[index])
            ),
          ),
      bottomSheet: _buildMessageInput(),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  static void showRandomStatus(BuildContext context, ApiService apiService) async {
    final statusCodes = [200, 201, 400, 404, 500];
    Random random = Random();
    int randomStatusCode = statusCodes[random.nextInt(statusCodes.length)];
    await apiService.getHTTPStatus(randomStatusCode);
  }

  static void showStatusPicker(BuildContext context, ApiService apiService) {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          actions: [
            TextButton(
              onPressed: () {
                
              }, 
              child: const Text("100")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("200")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("201")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("400")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("401")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("403")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("404")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("418")
            ),
            TextButton(
              onPressed: () {

              }, 
              child: const Text("500")
            ),
            TextButton(
              onPressed: () async {
                HTTPStatusResponse httpStatusResponse = await apiService.getHTTPStatus(503);
                Image.network(httpStatusResponse.imageUrl);
              }, 
              child: const Text("503")
            ),
          ],
        );
      }
    );
  }
}
