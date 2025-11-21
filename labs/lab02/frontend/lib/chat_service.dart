import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    // Симуляция подключения
    await Future.delayed(Duration(milliseconds: 200));
  }

  Future<void> sendMessage(String msg) async {
    // Симуляция отправки сообщения
    await Future.delayed(Duration(milliseconds: 100));
    if (failSend) throw Exception('message sending failed');
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
