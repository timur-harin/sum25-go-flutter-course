import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller = StreamController<String>.broadcast();
  bool failSend = false;

  Future<void> connect() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate connection
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception("Failed to send");
    await Future.delayed(const Duration(milliseconds: 500));
    _controller.add(msg); // Simulate receiving the same message back
  }

  Stream<String> get messageStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
