import 'package:flutter/material.dart';
import 'dart:async';
import '../services/websocket_service.dart';

class WebSocketScreen extends StatefulWidget {
  const WebSocketScreen({super.key});

  @override
  State<WebSocketScreen> createState() => _WebSocketScreenState();
}

class _WebSocketScreenState extends State<WebSocketScreen> {
  final WebSocketService _webSocketService = WebSocketService();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _delayController = TextEditingController();
  final List<WebSocketMessage> _messages = [];

  bool _isConnected = false;
  bool _isConnecting = false;

  // Stream subscriptions for proper cleanup
  late StreamSubscription<WebSocketMessage> _messageSubscription;
  late StreamSubscription<bool> _connectionSubscription;

  @override
  void initState() {
    super.initState();
    _userIdController.text =
        'user_${DateTime.now().millisecondsSinceEpoch % 10000}';
    _delayController.text = '0';

    // Listen to messages
    _messageSubscription = _webSocketService.messages.listen((message) {
      if (mounted) {
        // Check if widget is still mounted
        setState(() {
          _messages.add(message);
        });
        // Auto-scroll to bottom
        if (_messages.length > 20) {
          setState(() {
            _messages.removeAt(0);
          });
        }
      }
    });

    // Listen to connection status
    _connectionSubscription =
        _webSocketService.connectionStatus.listen((connected) {
      if (mounted) {
        // Check if widget is still mounted before calling setState
        setState(() {
          _isConnected = connected;
          _isConnecting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _connectionSubscription.cancel();
    _webSocketService.dispose();
    _messageController.dispose();
    _userIdController.dispose();
    _delayController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    if (_userIdController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a user ID')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
    });

    const wsUrl = 'ws://localhost:8081/ws';
    final userId = _userIdController.text.trim().isNotEmpty
        ? _userIdController.text.trim()
        : null;

    await _webSocketService.connect(wsUrl, userId: userId);

    if (!mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to connect to WebSocket server')),
      );
    }
  }

  Future<void> _disconnect() async {
    await _webSocketService.disconnect();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || !_isConnected) return;

    final delay = int.tryParse(_delayController.text) ?? 0;

    if (delay > 0) {
      _webSocketService.sendDelayedMessage(message, delay);
    } else {
      _webSocketService.sendMessage(message);
    }

    _messageController.clear();
  }

  void _sendPing() {
    _webSocketService.sendPing();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  Color _getMessageColor(String messageType) {
    switch (messageType) {
      case 'system':
        return Colors.blue;
      case 'notification':
        return Colors.orange;
      case 'pong':
        return Colors.green;
      default:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WebSocket Chat'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.cloud_done : Icons.cloud_off),
            onPressed: _sendPing,
            tooltip: _isConnected ? 'Connected - Send Ping' : 'Disconnected',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection Panel
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userIdController,
                        decoration: const InputDecoration(
                          labelText: 'User ID',
                          border: OutlineInputBorder(),
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        enabled: !_isConnected,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 120,
                      child: ElevatedButton(
                        onPressed: _isConnecting
                            ? null
                            : (_isConnected ? _disconnect : _connect),
                        child: _isConnecting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_isConnected ? 'Disconnect' : 'Connect'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _isConnected ? Icons.circle : Icons.circle_outlined,
                      color: _isConnected ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isConnected
                          ? 'Connected to WebSocket server'
                          : 'Not connected',
                      style: TextStyle(
                        color: _isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet.\nConnect and start chatting!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isOwnMessage =
                          message.user == _webSocketService.currentUserId;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          mainAxisAlignment: isOwnMessage
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 8.0,
                                ),
                                decoration: BoxDecoration(
                                  color: isOwnMessage
                                      ? Colors.blue[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (!isOwnMessage ||
                                        message.type != 'message') ...[
                                      Text(
                                        message.user,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: _getMessageColor(message.type),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                    ],
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: _getMessageColor(message.type),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          _formatTimestamp(message.timestamp),
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (message.delay != null &&
                                            message.delay! > 0) ...[
                                          const SizedBox(width: 4),
                                          Text(
                                            '(${message.delay}ms delay)',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.orange,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Message Input
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Delay control
                Row(
                  children: [
                    const Text('Delay (ms): '),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _delayController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isConnected ? _sendPing : null,
                      icon: const Icon(Icons.network_ping),
                      label: const Text('Ping'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Message input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        enabled: _isConnected,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isConnected ? _sendMessage : null,
                      child: const Text('Send'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
