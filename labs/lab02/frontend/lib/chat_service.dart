import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> sendMessage(String msg) async {
    // Simulate sending delay
    await Future.delayed(const Duration(milliseconds: 500));
    if (failSend) {
      throw Exception('Failed to send message');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
