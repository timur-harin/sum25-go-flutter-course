import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // StreamController to simulate incoming messages for tests
  final StreamController<String> _controller = StreamController<String>.broadcast();
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    // Simulate connection delay
    await Future.delayed(Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    // Simulate sending a message
    if (failSend) {
      throw Exception('Send failed');
    }
    await Future.delayed(Duration(milliseconds: 10));
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // Return stream of incoming messages
    return _controller.stream;
  }
}
