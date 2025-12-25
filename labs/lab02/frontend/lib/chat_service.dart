import 'dart:async';

/// A chat message model used in the frontend.
class ChatMessage {
  final String sender;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.content,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// ChatService provides a stream of incoming messages and a method to send messages.
class ChatService {
  final _controller = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _controller.stream;

  /// Simulate sending a message to the backend.
  Future<void> sendMessage(ChatMessage msg) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 500));
    // echo back the message as confirmation
    _controller.sink.add(msg);
  }

  Timer? _mockTimer;

  /// Starts generating mock incoming messages every 10 seconds.
  void startMocking() {
    _mockTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      final incoming = ChatMessage(
        sender: 'Server',
        content: 'Automated ping at ${DateTime.now().toLocal()}',
      );
      _controller.sink.add(incoming);
    });
  }

  /// Clean up resources.
  void dispose() {
    _mockTimer?.cancel();
    _controller.close();
  }
}