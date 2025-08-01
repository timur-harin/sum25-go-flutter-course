import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;

  ChatService({this.failSend = false});

  Future<void> connect() async {
    // TODO: Simulate connection (for tests)
    // await Future.delayed(...)
    await Future.delayed(Duration(milliseconds: 400));
    _controller.add('system was connected');
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    // await Future.delayed(...)
    // _controller.add(msg)
    await Future.delayed(Duration(milliseconds: 400));

    if (failSend) {
      _controller.addError('error was detected, failed to send message');
      return;
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // TODO: Return stream of incoming messages (for tests)
    return _controller.stream;
  }
  void dispose() {
    _controller.close();
  }
}
