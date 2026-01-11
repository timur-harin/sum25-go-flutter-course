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
    await Future.delayed(Duration(seconds: 1));

    if (failConnect) {
      throw Exception("Fail to connect");
    }
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    // await Future.delayed(...)
    // _controller.add(msg)
    await Future.delayed(Duration(seconds: 1));

    if (failSend) {
      throw Exception("Fail to send");
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // TODO: Return stream of incoming messages (for tests)
    return _controller.stream;
  }
}
