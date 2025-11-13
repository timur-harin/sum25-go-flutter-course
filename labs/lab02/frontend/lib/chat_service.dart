import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;
  bool failConnect = false;

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (failConnect) {
      throw Exception('Connect failed');
    }
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(const Duration(milliseconds: 10));
    if (failSend) {
      throw Exception('Send failed');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}
