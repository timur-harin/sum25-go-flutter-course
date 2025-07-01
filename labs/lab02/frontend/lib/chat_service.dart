import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failConnect = false;

  ChatService();

  Future<void> connect() async {
    if (failConnect) {
      throw Exception('Failed to connect');
    }
    await Future.delayed(const Duration(seconds: 1));
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(const Duration(seconds: 1));
    connect();
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
