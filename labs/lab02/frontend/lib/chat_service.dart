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
  bool _connected = false;

  ChatService();

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (failConnect) throw Exception('Connection failed');
    _connected = true;
    _controller.add('[system] Connected to chat');
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    if (!_connected) {
      _controller.add('[system] Not connected');
      return;
    }
    await Future.delayed(const Duration(milliseconds: 50));
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
