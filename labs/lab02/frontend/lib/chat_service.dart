import 'dart:async';

class ChatService {
  final StreamController<String> _controller = StreamController<String>();
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    return;
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
