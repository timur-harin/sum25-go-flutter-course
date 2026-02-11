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
    // await Future.delayed(...)
    if (failConnect) {
      throw Exception("Failed to connect");
    }
    await Future.delayed(Duration(seconds: 2));
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    // await Future.delayed(...)
    // _controller.add(msg)
    if (failSend) {
      throw Exception("Failed to send");
    }
    await Future.delayed(Duration(milliseconds: 10));
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // TODO: Return stream of incoming messages (for tests)
    return _controller.stream;
  }
}
