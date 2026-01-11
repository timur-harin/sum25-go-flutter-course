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
    if (failConnect) throw Exception('Connection failed');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    await Future.delayed(const Duration(milliseconds: 100));
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}
