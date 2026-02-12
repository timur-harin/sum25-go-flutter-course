import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // StreamController to simulate incoming messages
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  bool failSend = false;
  bool failConnect = false;

  ChatService();

  // Simulate connection (can fail)
  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (failConnect) {
      throw Exception('Connect failed');
    }
    // Otherwise, success: do nothing
  }

  // Simulate sending a message (can fail)
  Future<void> sendMessage(String msg) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (failSend) {
      throw Exception('Send failed');
    }
    _controller.add(msg);
  }

  // Stream of incoming messages
  Stream<String> get messageStream => _controller.stream;

  // Dispose method to close stream when needed
  void dispose() {
    _controller.close();
  }
}
