import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;


  bool failConnect = false;


  ChatService();

  Future<void> connect() async {
    await Future.delayed(Duration(milliseconds: 500));
    if (failConnect) {
      throw Exception('Failed to connect to server.');
    }
    _controller.add('[System] Connected');
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(Duration(milliseconds: 300));
    if (failSend) {
      throw Exception('Failed to send message.');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }

  void dispose() {
    _controller.close();

  }
}
