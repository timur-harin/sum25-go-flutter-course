import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;
  bool failConnect = false;

  ChatService();

  Future<void> connect() async {
    if (failConnect) {
      throw Exception('Connect failed');
    }
    // Simulate connection delay
    await Future.delayed(Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Send failed');
    }
    // Simulate sending delay
    await Future.delayed(Duration(milliseconds: 10));
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
