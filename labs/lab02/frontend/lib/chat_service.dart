import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failConnect = false;
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    if (failConnect) {
      throw Exception('Connection failed');
    }
    await Future.delayed(Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Send failed');
    }
    await Future.delayed(Duration(milliseconds: 10));
    _controller.add('[Sent] $msg');
  }

  Stream<String> get messageStream => _controller.stream;

  void addMessage(String msg) {
    _controller.add(msg);
  }

  void dispose() {
    _controller.close();
  }
}
