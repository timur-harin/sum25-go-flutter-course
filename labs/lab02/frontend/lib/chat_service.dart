import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    // Simulate connection delay
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Send failed');
    }
    await Future.delayed(Duration(milliseconds: 10));
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}