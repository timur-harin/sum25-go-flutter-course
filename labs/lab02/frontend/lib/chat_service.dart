import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  final StreamController<String> _controller =
  StreamController<String>.broadcast();
  // TODO: Add simulation flags for connection and send failures
  bool failConnect = false;
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    // TODO: Simulate connection (for tests)
    await Future.delayed(Duration(milliseconds: 10));
    if (failConnect) {
      throw Exception('Simulated connection failure');
    }
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    await Future.delayed(Duration(milliseconds: 10));
    if (failSend) {
      throw Exception('Simulated send failure');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // TODO: Return stream of incoming messages (for tests)
    return _controller.stream;
  }
}