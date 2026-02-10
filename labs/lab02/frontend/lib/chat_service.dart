import 'dart:async';

/// Abstract chat service definition
abstract class ChatService {
  Stream<String> get messageStream;
  Future<void> connect();
  Future<void> sendMessage(String msg);
}

/// Mock implementation simulating backend interaction
class MockChatService extends ChatService {
  final StreamController<String> _controller = StreamController<String>.broadcast();
  bool failSend = false;

  @override
  Stream<String> get messageStream => _controller.stream;

  @override
  Future<void> connect() async {
    // Simulate some delay if needed
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Send failed');
    }
    _controller.add(msg);
  }

  /// Dispose method for cleanup (optional, but good practice)
  void dispose() {
    _controller.close();
  }
}