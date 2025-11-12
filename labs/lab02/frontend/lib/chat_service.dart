import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  bool failConnect = false;
  bool failSend = false;
  ChatService();

  Future<void> connect() async {
    if (failConnect) throw Exception('Connection failed');
    await Future.delayed(Duration(milliseconds: 1));
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(Duration(milliseconds: 1));
    if (failSend) throw Exception('Send failed');
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
