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
  Duration connectDelay;
  Duration sendDelay;

  ChatService({
    this.connectDelay = const Duration(milliseconds: 100),
    this.sendDelay = const Duration(milliseconds: 50),
  });

  Future<void> connect() async {
    if (failConnect) {
      await Future.delayed(connectDelay);
      _controller.addError('Connection failed');
      return Future.error('Connection failed');
    }
    await Future.delayed(connectDelay);
    _controller.add('Welcome to the chat!');
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      await Future.delayed(sendDelay);
      _controller.addError('Send failed');
      return Future.error('Send failed');
    }
    await Future.delayed(sendDelay);
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
  void dispose() {
    _controller.close();
  }
}
