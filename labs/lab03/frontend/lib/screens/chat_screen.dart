import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ChatProvider>(context, listen: false).loadMessages();
    });
    // TODO: Call _loadMessages() to load initial data
  }

  @override
  void dispose() {
    // TODO: Dispose controllers and API service
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      _messages = await _apiService.getMessages();
    } catch (error) {
      _error = error.toString();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
    // Update _messages with result
    // Catch any exceptions and set _error
    // Set _isLoading = false in finally block
    // Call setState() to update UI
  }

  Future<void> _sendMessage() async {
    final String username = _usernameController.text.trim();
    final String content = _messageController.text.trim();

    // Validate that both fields are not empty
    if (username.isEmpty || content.isEmpty) {
      setState(() {
        _error = 'Username and message cannot be empty.';
      });
      return;
    }

    final CreateMessageRequest request = CreateMessageRequest(
      username: username,
      content: content,
    );

    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You successfully sent message')),
        );
      }
      await Provider.of<ChatProvider>(context, listen: false).createMessage(request);
      _messageController.clear();
    } catch (e) {
      setState(() {
        _error = 'Failed to send message: ${e.toString()}';
      });
    }
    // TODO: Implement _sendMessage
    // Get username and content from controllers
    // Validate that both fields are not empty
    // Create CreateMessageRequest
    // Try to send message using _apiService.createMessage()
    // Add new message to _messages list
    // Clear the message controller
    // Catch any exceptions and show error
    // Call setState() to update UI
  }

  Future<void> _editMessage(Message message) async {
    final TextEditingController editController =
        TextEditingController(text: message.content);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Message'),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              labelText: 'Message',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (!context.mounted) {
                  return;
                }
                final String updatedContent = editController.text.trim();

                if (updatedContent.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message cannot be empty.')),
                  );
                  return;
                }

                final UpdateMessageRequest request =
                    UpdateMessageRequest(content: updatedContent);

                try {
                  await Provider.of<ChatProvider>(context)
                      .updateMessage(message.id, request);

                  // Close the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  // Catch any exceptions and show error
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Failed to update message: ${e.toString()}')),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    // TODO: Implement _editMessage
    // Show dialog with text field pre-filled with message content
    // Allow user to edit the content
    // When saved, create UpdateMessageRequest
    // Try to update message using _apiService.updateMessage()
    // Update the message in _messages list
    // Catch any exceptions and show error
    // Call setState() to update UI
  }

  Future<void> _deleteMessage(Message message) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed Cancel
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Confirm
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await Provider.of<ChatProvider>(context, listen: false).deleteMessage(message.id);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete message: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(BuildContext context, int statusCode) async {
    try {
      HTTPStatusResponse status = await _apiService.getHTTPStatus(statusCode);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('HTTP Status: ${status.statusCode}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(status.description),
              const SizedBox(height: 16),
              Image.network(
                status.imageUrl,
                height: 200,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Failed to load image'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue,
        child: Text(
          message.username != "" ? message.username[0].toUpperCase() : '?',
          style: const TextStyle(color: Colors.white),
        ), // You can customize the color
      ),
      title: Text('${message.username} - ${message.timestamp}'),
      subtitle: Text(message.content),
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'Edit') {
            _editMessage(message); // Implement edit functionality
          } else if (value == 'Delete') {
            _deleteMessage(message); // Implement delete functionality
          }
        },
        itemBuilder: (BuildContext context) {
          return {'Edit', 'Delete'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
      onTap: () {
        var codes = [200, 404, 500];
        _showHTTPStatus(context,
            codes[Random().nextInt(codes.length)]);
      },
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Enter your username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Enter your message',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (value) {
              _sendMessage();
              _messageController
                  .clear();
            },
          ),
          const SizedBox(height: 8.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () {
                  _sendMessage();
                  _messageController
                      .clear(); // Clear the message input after sending
                },
                child: const Text('Send'),
              ),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _showHTTPStatus(
                          context, 200);
                    },
                    child: const Text('200 OK'),
                  ),
                  const SizedBox(width: 2.0),
                  ElevatedButton(
                    onPressed: () {
                      _showHTTPStatus(
                          context, 404);
                    },
                    child: const Text('404 Not Found'),
                  ),
                  const SizedBox(width: 2.0),
                  ElevatedButton(
                    onPressed: () {
                      _showHTTPStatus(context, 500);
                    },
                    child: const Text('500 Error'),
                  ),
                ],
              ),
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
          const Icon(
            Icons.error_outline,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'An error occurred. Please try again.',
            style: TextStyle(
              color: Colors.red,
              fontSize: 18.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _loadMessages, // Method to retry loading messages
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, // Button color
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
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
    // - AppBar with title "REST API Chat" and refresh action
    // - Body that shows loading, error, or message list based on state
    // - BottomSheet with message input
    // - FloatingActionButton for refresh
    // Handle different states: loading, error, success
    return Scaffold(
      appBar: AppBar(title: const Text('REST API Chat'), actions: [
        IconButton(
            icon: const Icon(Icons.refresh), onPressed: () => _loadMessages())
      ]),
      body: Column(
        children: [
          _isLoading
              ? _buildLoadingWidget()
              : _error != null
                  ? _buildErrorWidget()
                  : _messages.isEmpty
                      ? const Center(
                          child: Column(
                          children: [
                            Text('No messages yet'),
                            Text('Send your first message to get started!')
                          ],
                        ))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final message = _messages[index];
                              return _buildMessageTile(message);
                            },
                          ),
                        ),
          _buildMessageInput(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  static showRandomStatus(BuildContext context, ApiService apiService) async {
    var statusCodes = [200, 201, 400, 404, 500];
    Random rnd = Random();
    var code = statusCodes[rnd.nextInt(statusCodes.length)];

    try {
      final resp = await apiService.getHTTPStatus(code);
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('HTTP Status: ${resp.statusCode}'),
            content: Column(
              children: [
                Text(resp.description),
                const SizedBox(height: 16),
                Image.network(resp.imageUrl),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              )
            ],
          ),
        );
      }
    } catch (_) {}
  }

  static showStatusPicker(BuildContext context, ApiService apiService) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Pick Status Code'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [100, 200, 201, 400, 401, 403, 404, 418, 500, 503]
                .map((code) => ListTile(
                      title: Text(code.toString()),
                      onTap: () {
                        Navigator.pop(ctx);
                        apiService.getHTTPStatus(code).then((resp) {
                          showDialog(
                            context: context,
                            builder: (c) => AlertDialog(
                              title: Text('Status: ${resp.statusCode}'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(resp.description),
                                  const SizedBox(height: 16),
                                  Image.network(resp.imageUrl),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(c),
                                  child: const Text('Close'),
                                )
                              ],
                            ),
                          );
                        });
                      },
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
// Show dialog with buttons for different status codes
// Allow user to pick which HTTP cat they want to see
// Common codes: 100, 200, 201, 400, 401, 403, 404, 418, 500, 503
}
