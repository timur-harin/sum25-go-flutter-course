import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketMessage {
  final String type;
  final String content;
  final String user;
  final DateTime timestamp;
  final int? delay;

  WebSocketMessage({
    required this.type,
    required this.content,
    required this.user,
    required this.timestamp,
    this.delay,
  });

  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    return WebSocketMessage(
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      user: json['user'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      delay: json['delay'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'content': content,
      'user': user,
      'timestamp': timestamp.toUtc().toIso8601String(),
      if (delay != null) 'delay': delay,
    };
  }

  @override
  String toString() {
    return 'WebSocketMessage(type: $type, content: $content, user: $user, timestamp: $timestamp)';
  }
}

class WebSocketService {
  static const String defaultUrl = 'ws://localhost:8081/ws';

  WebSocketChannel? _channel;
  StreamController<WebSocketMessage> _messageController =
      StreamController<WebSocketMessage>.broadcast();
  StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  String? _currentUserId;
  bool _isConnected = false;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int maxReconnectAttempts = 5;

  // Getters
  Stream<WebSocketMessage> get messages => _messageController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;
  bool get isConnected => _isConnected;
  String? get currentUserId => _currentUserId;

  /// Connect to WebSocket server
  Future<void> connect(String url, {String? userId}) async {
    print('🔌 Attempting to connect to WebSocket: $url');
    print('👤 User ID: ${userId ?? "anonymous"}');

    if (_isConnected) {
      print('⚠️ Already connected to WebSocket');
      return;
    }

    try {
      _currentUserId = userId;
      _channel = WebSocketChannel.connect(Uri.parse(url));

      print('🔗 WebSocket channel created, waiting for connection...');

      // Listen to the stream
      _channel!.stream.listen(
        (message) {
          print('📨 WebSocket message received: $message');
          try {
            final jsonData = jsonDecode(message) as Map<String, dynamic>;
            final webSocketMessage = WebSocketMessage.fromJson(jsonData);
            _messageController.add(webSocketMessage);
            print('✅ Message processed successfully');
          } catch (e) {
            print('❌ Error parsing message: $e');
          }
        },
        onError: (error) {
          print('💥 WebSocket error: $error');
          _handleConnectionError();
        },
        onDone: () {
          print('🔌 WebSocket connection closed');
          _handleConnectionClosed();
        },
      );

      _isConnected = true;
      _connectionController.add(true);
      _startPingTimer();

      print('✅ WebSocket connected successfully');
    } catch (e) {
      print('💥 Failed to connect to WebSocket: $e');
      _handleConnectionError();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _stopPingTimer();
    _stopReconnectTimer();

    if (_channel != null) {
      await _channel!.sink
          .close(status.normalClosure); // Use 1000 instead of 1001
      _channel = null;
    }

    _isConnected = false;
    _connectionController.add(false);
  }

  /// Send a message
  void sendMessage(String content, {String type = 'message', int? delay}) {
    if (!_isConnected || _channel == null) {
      print('❌ Cannot send message: not connected');
      return;
    }

    final message = WebSocketMessage(
      type: type,
      content: content,
      user: _currentUserId ?? 'anonymous',
      timestamp: DateTime.now(),
      delay: delay,
    );

    try {
      print('📤 Sending message: ${message.content}');
      _channel!.sink.add(jsonEncode(message.toJson()));
      print('✅ Message sent successfully');
    } catch (e) {
      print('💥 Error sending message: $e');
    }
  }

  /// Send a ping message
  void sendPing() {
    sendMessage('ping', type: 'ping');
  }

  /// Send a delayed message for testing
  void sendDelayedMessage(String content, int delayMs) {
    sendMessage(content, delay: delayMs);
  }

  /// Handle connection errors
  void _handleConnectionError() {
    print('🔧 Handling connection error');
    _isConnected = false;
    _connectionController.add(false);
    _stopPingTimer();
  }

  /// Handle connection closed
  void _handleConnectionClosed() {
    print('🔧 Handling connection closed');
    _isConnected = false;
    _connectionController.add(false);
    _stopPingTimer();
  }

  void _onMessage(dynamic data) {
    try {
      final jsonData = jsonDecode(data as String);
      final message = WebSocketMessage.fromJson(jsonData);
      _messageController.add(message);

      // Handle pong responses
      if (message.type == 'pong') {
        print('Received pong from server');
      }
    } catch (e) {
      print('Error parsing message: $e');
    }
  }

  void _onError(error) {
    print('WebSocket error: $error');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _onDisconnected() {
    print('WebSocket disconnected');
    _isConnected = false;
    _connectionController.add(false);
    _scheduleReconnect();
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        sendPing();
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      print('Max reconnection attempts reached');
      return;
    }

    _stopReconnectTimer();

    final delay = Duration(
        seconds: math.min(30, math.pow(2, _reconnectAttempts).toInt()));
    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && _currentUserId != null) {
        print('Attempting to reconnect... (attempt ${_reconnectAttempts + 1})');
        _reconnectAttempts++;
        connect(_currentUserId!);
      }
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Get connection statistics
  Future<Map<String, dynamic>?> getStats() async {
    try {
      // This would typically call the HTTP stats endpoint
      final response = await http.get(Uri.parse('http://localhost:8081/stats'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error getting stats: $e');
    }
    return null;
  }

  /// Dispose resources
  void dispose() {
    _stopPingTimer();
    _stopReconnectTimer();
    disconnect();
    _messageController.close();
    _connectionController.close();
  }
}
