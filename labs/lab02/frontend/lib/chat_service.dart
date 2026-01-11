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
    await Future.delayed(Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    // Simulate sending delay
    await Future.delayed(Duration(milliseconds: 10));
    if (failSend) throw Exception('Send failed');
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}
