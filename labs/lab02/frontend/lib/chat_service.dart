import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;
  bool failConnection = false;

  ChatService();

  Future<void> connect() async {
    await Future.delayed(const Duration(microseconds: 500));
    if (failConnection) {
      throw Exception("Connection failed");
    }
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(const Duration(seconds: 1));
    if (failSend) {
      throw Exception("Send failed");
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
