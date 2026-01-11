import 'package:flutter/material.dart';
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // TODO: Add final ApiService _apiService = ApiService();
  final ApiService _apiService = ApiService();
  // TODO: Add List<Message> _messages = [];
  List<Message> _messages = [];
  // TODO: Add bool _isLoading = false;
  bool _isLoading = false;
  // TODO: Add String? _error;
  String? _error;
  // TODO: Add final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  // TODO: Add final TextEditingController _messageController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // TODO: Call _loadMessages() to load initial data
    _loadMessages();
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and API service
    super.dispose();
    _usernameController.dispose();
    _messageController.dispose();
    _apiService.dispose();
  }

  Future<void> _loadMessages() async {
    // TODO: Implement _loadMessages
    // Set _isLoading = true and _error = null
    setState(() {
      _isLoading = true;
      _error = null;
    });
    // Try to get messages from _apiService.getMessages()
    // Update _messages with result
    try {
      final msgs = await _apiService.getMessages();
      setState(() {
        _messages = msgs;
      });
    } catch (e) {
      // Catch any exceptions and set _error
      setState(() {
        _error = e.toString();
      });
    } finally {
      // Set _isLoading = false in finally block
      setState(() {
        _isLoading = false;
      });
      // Call setState() to update UI
    }
  }

  Future<void> _sendMessage() async {
    // TODO: Implement _sendMessage
    // Get username and content from controllers
    var username = _usernameController.text;
    var content = _messageController.text;
    // Validate that both fields are not empty
    if (username.isEmpty || content.isEmpty) {
      return;
    }
    // Create CreateMessageRequest
    CreateMessageRequest request = CreateMessageRequest(username: username, content: content);
    // Try to send message using _apiService.createMessage()
    // Add new message to _messages list
    // Clear the message controller
    try {
      _messages.add(await _apiService.createMessage(request));
      _messageController.clear();
    } catch (e) {
      // Catch any exceptions and show error
      setState(() {
        _error = e.toString();
      });
    }
    // Catch any exceptions and show error
    // Call setState() to update UI
    setState(() {});
  }

  Future<void> _editMessage(Message message) async {
    // TODO: Implement _editMessage
    // Show dialog with text field pre-filled with message content
    // Allow user to edit the content
    final textController = TextEditingController(text: message.content);
    final editedContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: "Enter your message",
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context, textController.text),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    // When saved, create UpdateMessageRequest
    if (editedContent != null && editedContent != message.content) {
      // Try to update message using _apiService.updateMessage()
      try {
        final request = UpdateMessageRequest(content: editedContent);

        final err = request.validate();
        if (err != null) {
          setState(() {
            _error = err;
          });
          return;
        }

        // Update the message in _messages list
        final updMsg = await _apiService.updateMessage(message.id, request);
        final index = _messages.indexWhere((m) => m.id == message.id);
        if (index != -1) {
          _messages[index] = updMsg;
        }
      } catch (e) {
        // Catch any exceptions and show error
        setState(() {
          _error = e.toString();
        });
      }
      // Call setState() to update UI
      setState(() {});
    } 
  }

  Future<void> _deleteMessage(Message message) async {
    // TODO: Implement _deleteMessage
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message"),
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
    ) ?? false;
  
    // If confirmed, try to delete using _apiService.deleteMessage()
    if (confirmed){
      try {
        await _apiService.deleteMessage(message.id);

        // Remove message from _messages list
        setState(() {
            _messages.removeWhere((m) => m.id == message.id);
        });
      } catch (e) {
        // Catch any exceptions and show error
        setState(() {
          _error = e.toString();
        });
      }
    }
    // Call setState() to update UI
    setState(() {});
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    // TODO: Implement _showHTTPStatus
    // Try to get HTTP status info using _apiService.getHTTPStatus()
    try {
      final statusInfo = await _apiService.getHTTPStatus(statusCode);
      // Show dialog with status code, description, and HTTP cat image
      // Use Image.network() to display the cat image
      // http.cat
      showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Status code: $statusCode"),
        content: Column(
          children: [
            Text("Description: ${statusInfo.description}"),
            const SizedBox(height: 16),
            Image.network(
              'https://http.cat/$statusCode.jpg',
              // Handle loading and error states for the image
              loadingBuilder: (context, child, loadingProccess) {
                if (loadingProccess == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProccess.expectedTotalBytes != null ?
                    loadingProccess.cumulativeBytesLoaded / loadingProccess.expectedTotalBytes! : null
                  )
                );
              },
              errorBuilder: (context, error, StackTrace) {
                return const Text("Could not load cat image");
              },
            )
          ]
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"))
        ],
        ),
    );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Widget _buildMessageTile(Message message) {
    // TODO: Implement _buildMessageTile
    // Return ListTile with:
    return Container( child: ListTile(
      // - leading: CircleAvatar with first letter of username
      leading: CircleAvatar(child: Text(message.username[0])),
      // - title: Text with username and timestamp
      title: Text("${message.username} ${message.timestamp}"),
      // - subtitle: Text with message content
      subtitle: Text(message.content),
      // - trailing: PopupMenuButton with Edit and Delete options
      trailing: PopupMenuButton<String>(
        onSelected: (String item) {
          if (item == "edit") {
            _editMessage(message);
          } else if (item == "delete") {
            _deleteMessage(message);
          }
        },
        itemBuilder: (context) {
          return <PopupMenuEntry<String>>[
            const PopupMenuItem<String>(value: 'edit', child: Text("Edit")),
            const PopupMenuItem<String>(value: 'delete', child: Text("Delete"))
          ];
        },
      ),
      // - onTap: Show HTTP status dialog for random status code (200, 404, 500)
      onTap: () => {_showHTTPStatus((([200, 404, 500].toList()..shuffle()).first))},
    )); // Placeholder
  }

  Widget _buildMessageInput() {
    // TODO: Implement _buildMessageInput
    // Return Container with:
    return Container(
    // - Padding and background color
    padding: const EdgeInsets.all(16.0),
    color: Colors.blueGrey,
    // - Column with username TextField and message TextField
    child: Column(
      children: [
        // - Connect controllers to text fields
        TextField(controller: _usernameController),
        TextField(controller: _messageController, decoration: const InputDecoration(hintText: "Type a message"),),
        // - Row with Send button and HTTP Status demo buttons (200, 404, 500)
        Row(children: [
          // - Handle send button press
          TextButton(onPressed: _sendMessage, child: const Text("Send")),
          TextButton(onPressed: () => {_showHTTPStatus(200)}, child: const Text("200")),
          TextButton(onPressed: () => {_showHTTPStatus(404)}, child: const Text("404")),
          TextButton(onPressed: () => {_showHTTPStatus(500)}, child: const Text("500")),
        ],)
      ],
    ),
    ); // Placeholder
  }

  Widget _buildErrorWidget() {
    // TODO: Implement _buildErrorWidget
    // Return Center widget with:
    return Center(
      // - Column containing error icon, error message, and retry button
      child: Column(children: [
        const Icon(Icons.error),
        // - Red color scheme for error state
        Text("Message: $_error", style: const TextStyle(color: Colors.red),),
        // - Retry button should call _loadMessages()
        TextButton(onPressed: _loadMessages, child: const Text("Retry"))
      ],),
    ); // Placeholder
  }

  Widget _buildLoadingWidget() {
    // TODO: Implement _buildLoadingWidget
    // Return Center widget with CircularProgressIndicator
    return const Center(child: CircularProgressIndicator()); // Placeholder
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement build method
    // Return Scaffold with:
    // Handle different states: loading, error, success
    return Scaffold(
      // - AppBar with title "REST API Chat" and refresh action
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [IconButton(onPressed: _loadMessages, icon: const Icon(Icons.refresh))],
      ),
      // - Body that shows loading, error, or message list based on state
      body: Column(
        children: [
          Expanded(
            child: _isLoading ? _buildLoadingWidget() : 
            _error != null ? _buildErrorWidget() : ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageTile(_messages[index]);
              },
            )
          ),
      // - BottomSheet with message input
      BottomSheet(onClosing: () {}, builder: (context) {
        return _buildMessageInput();
      })
        ],
      ),
      // - FloatingActionButton for refresh
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  // // TODO: Add static method showRandomStatus(BuildContext context, ApiService apiService)
  // const showRandomStatus(BuildContext context, ApiService apiService) {
  //   // Generate random status code from [200, 201, 400, 404, 500]
  //   final status =  (([200, 201, 400, 404, 500].toList()..shuffle()).first);
  //   // Call _showHTTPStatus with the random code
  //   // This demonstrates different HTTP cat images
  // }

  // TODO: Add static method showStatusPicker(BuildContext context, ApiService apiService)
  // Show dialog with buttons for different status codes
  // Allow user to pick which HTTP cat they want to see
  // Common codes: 100, 200, 201, 400, 401, 403, 404, 418, 500, 503
}
