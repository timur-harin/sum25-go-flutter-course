import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;

  ChatService() {
    Timer.periodic(const Duration(microseconds: 5), (timer) {
      _controller.add("Incoming message at ${DateTime.now()}");
    });
  }

  Future<void> connect() async {
    // TODO: Simulate connection (for tests)
    await Future.delayed(const Duration(milliseconds: 5));
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    if (failSend) {
      throw Exception("Fake failure");
    }
    await Future.delayed(const Duration(milliseconds: 5));
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
