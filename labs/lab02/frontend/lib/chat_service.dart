import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
  StreamController<String>.broadcast();

  bool failSend = false;
  bool failConnect = false;

  Future<void> connect() async {
    if (failConnect) {
      throw Exception('Connection failed');
    }
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Send failed');
    }
    await Future.delayed(const Duration(milliseconds: 10));
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}