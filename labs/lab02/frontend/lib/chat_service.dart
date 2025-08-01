import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;
  bool failConnect = false;

  ChatService();

  Future<void> connect() async {
    await Future.delayed(Duration(seconds: 1));
    if (failConnect) {
      throw Exception("Connection error");
    }
    _controller.add("System: connected");
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (failSend) {
      throw Exception("Simulated send failure");
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
