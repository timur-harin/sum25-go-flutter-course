import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/message.dart';
import '../services/api_service.dart';
import '../main.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late ApiService _apiService;
  ChatProvider? _chatProvider;
  List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    print('🔧 ChatScreen: initState called');
    // Automatically load messages after a short delay to allow the UI to build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🔧 ChatScreen: Post frame callback - loading messages');
      _loadMessages();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('🔧 ChatScreen: didChangeDependencies called');
    // Try to get ChatProvider first, then fallback to ApiService
    try {
      _chatProvider = Provider.of<ChatProvider>(context, listen: false);
      _apiService = Provider.of<ApiService>(context, listen: false);
      print(
          '🔧 ChatScreen: Successfully got ChatProvider and ApiService from Provider');
    } catch (e) {
      print('🔧 ChatScreen: Failed to get from Provider: $e');
      // Fallback to creating our own ApiService for backwards compatibility
      _apiService = ApiService();
      print('🔧 ChatScreen: Created fallback ApiService');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _messageController.dispose();
    // Only dispose if we created our own ApiService
    if (_chatProvider == null) {
      try {
        Provider.of<ApiService>(context, listen: false);
      } catch (e) {
        _apiService.dispose();
      }
    }
    super.dispose();
  }

  Future<void> _loadMessages() async {
    print('🔧 ChatScreen: Starting to load messages');

    if (_chatProvider != null) {
      print('🔧 ChatScreen: Using ChatProvider');
      // Use ChatProvider if available
      await _chatProvider!.loadMessages();
      setState(() {
        _messages = _chatProvider!.messages;
        _isLoading = _chatProvider!.isLoading;
        _error = _chatProvider!.error;
        _initialized = true;
      });
      print(
          '🔧 ChatScreen: Messages loaded via ChatProvider: ${_messages.length} messages');
    } else {
      print('🔧 ChatScreen: Using direct ApiService');
      // Fallback to direct ApiService usage
      setState(() {
        _isLoading = true;
        _error = null;
        _initialized = true;
      });

      try {
        print('🔧 ChatScreen: Calling _apiService.getMessages()');
        final messages = await _apiService.getMessages();
        print(
            '🔧 ChatScreen: Successfully received ${messages.length} messages');
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      } catch (e) {
        print('🔧 ChatScreen: Error loading messages: $e');
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendMessage() async {
    if (!_initialized) {
      await _loadMessages(); // Initialize first
    }

    final username = _usernameController.text.trim();
    final content = _messageController.text.trim();

    if (username.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and message')),
      );
      return;
    }

    try {
      final request =
          CreateMessageRequest(username: username, content: content);

      if (_chatProvider != null) {
        // Use ChatProvider if available
        await _chatProvider!.createMessage(request);
        setState(() {
          _messages = _chatProvider!.messages;
        });
      } else {
        // Fallback to direct ApiService usage
        final newMessage = await _apiService.createMessage(request);
        setState(() {
          _messages.add(newMessage);
        });
      }

      _messageController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Message sent successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending message: $e')),
      );
    }
  }

  Future<void> _editMessage(Message message) async {
    final controller = TextEditingController(text: message.content);

    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Message'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter new message'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newContent != null &&
        newContent.isNotEmpty &&
        newContent != message.content) {
      try {
        final request = UpdateMessageRequest(content: newContent);

        if (_chatProvider != null) {
          // Use ChatProvider if available
          await _chatProvider!.updateMessage(message.id, request);
          setState(() {
            _messages = _chatProvider!.messages;
          });
        } else {
          // Fallback to direct ApiService usage
          final updatedMessage =
              await _apiService.updateMessage(message.id, request);
          setState(() {
            final index = _messages.indexWhere((m) => m.id == message.id);
            if (index != -1) {
              _messages[index] = updatedMessage;
            }
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating message: $e')),
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (_chatProvider != null) {
          // Use ChatProvider if available
          await _chatProvider!.deleteMessage(message.id);
          setState(() {
            _messages = _chatProvider!.messages;
          });
        } else {
          // Fallback to direct ApiService usage
          await _apiService.deleteMessage(message.id);
          setState(() {
            _messages.removeWhere((m) => m.id == message.id);
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting message: $e')),
        );
      }
    }
  }

  Future<void> _showHTTPStatus(int statusCode) async {
    try {
      HTTPStatusResponse statusResponse;

      if (_chatProvider != null) {
        // Use ChatProvider if available
        statusResponse = await _chatProvider!.getHTTPStatus(statusCode);
      } else {
        // Fallback to direct ApiService usage
        statusResponse = await _apiService.getHTTPStatus(statusCode);
      }

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('HTTP Status: ${statusResponse.statusCode}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusResponse.description),
                const SizedBox(height: 16),
                Image.network(
                  statusResponse.imageUrl,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Failed to load HTTP cat');
                  },
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading HTTP status: $e')),
      );
    }
  }

  Widget _buildMessageTile(Message message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(message.username.isNotEmpty
              ? message.username[0].toUpperCase()
              : '?'),
        ),
        title: Text(
          '${message.username} • ${_formatTimestamp(message.timestamp)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
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
            const PopupMenuItem(
              value: 'edit',
              child: Text('Edit'),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
        onTap: () {
          // Show random HTTP status for demonstration
          final statusCodes = [200, 404, 500];
          final randomCode = statusCodes[Random().nextInt(statusCodes.length)];
          _showHTTPStatus(randomCode);
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: Offset(0, -2),
            blurRadius: 4,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              hintText: 'Enter your username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your message',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _sendMessage,
                child: const Text('Send'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _showHTTPStatus(200),
                child: const Text('200 OK'),
              ),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(404),
                child: const Text('404 Not Found'),
              ),
              ElevatedButton(
                onPressed: () => _showHTTPStatus(500),
                child: const Text('500 Error'),
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
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            _error ?? 'An error occurred',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (!_initialized) {
                _loadMessages();
              } else {
                _loadMessages();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? _buildLoadingWidget()
                : _error != null
                    ? _buildErrorWidget()
                    : !_initialized || _messages.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'No messages yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Send your first message to get started!',
                                  style: TextStyle(color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              return _buildMessageTile(_messages[index]);
                            },
                          ),
          ),
          _buildMessageInput(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadMessages,
        tooltip: 'Refresh messages',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// Helper class for HTTP status demonstrations
class HTTPStatusDemo {
  static Future<void> showRandomStatus(
      BuildContext context, ApiService apiService) async {
    final statusCodes = [200, 201, 400, 404, 500];
    final randomCode = statusCodes[Random().nextInt(statusCodes.length)];

    try {
      final statusResponse = await apiService.getHTTPStatus(randomCode);

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Random HTTP Status: ${statusResponse.statusCode}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(statusResponse.description),
                const SizedBox(height: 16),
                Image.network(
                  statusResponse.imageUrl,
                  height: 200,
                  errorBuilder: (context, error, stackTrace) {
                    return const Text('Failed to load HTTP cat');
                  },
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
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading HTTP status: $e')),
      );
    }
  }

  static Future<void> showStatusPicker(
      BuildContext context, ApiService apiService) async {
    final statusCodes = [100, 200, 201, 400, 401, 403, 404, 418, 500, 503];

    final selectedCode = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose HTTP Status Code'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: statusCodes.map((code) {
              return ListTile(
                title: Text('$code'),
                onTap: () => Navigator.of(context).pop(code),
              );
            }).toList(),
          ),
        ),
      ),
    );

    if (selectedCode != null) {
      try {
        final statusResponse = await apiService.getHTTPStatus(selectedCode);

        if (context.mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('HTTP Status: ${statusResponse.statusCode}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(statusResponse.description),
                  const SizedBox(height: 16),
                  Image.network(
                    statusResponse.imageUrl,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) {
                      return const Text('Failed to load HTTP cat');
                    },
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
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading HTTP status: $e')),
        );
      }
    }
  }
}
