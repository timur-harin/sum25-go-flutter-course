
import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _controller.add('System: Welcome to the chat!');
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Failed to send message');
    }
    await Future.delayed(const Duration(milliseconds: 300));
    _controller.add('You: $msg');

    Future.delayed(const Duration(seconds: 1), () {
      _controller.add('Friend: Reply to "$msg"');
    });
  }

  Stream<String> get messageStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
