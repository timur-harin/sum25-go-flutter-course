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
    // TODO: Simulate connection (for tests)
    await Future.delayed(const Duration(milliseconds: 300));
    if (failConnect) throw Exception('Connect failed');
   }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    await Future.delayed(const Duration(milliseconds: 100));
    if (failSend) {
      throw Exception('Send failed');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
