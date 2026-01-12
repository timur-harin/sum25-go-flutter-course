import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller = StreamController<String>.broadcast();
  
  bool failConnect = false;
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    // TODO: Simulate connection (for tests)
    // await Future.delayed(...)
     if (failConnect) {
      return Future.delayed(Duration(milliseconds: 100), () => throw Exception('Connection failed'));
    }
    await Future.delayed(Duration(milliseconds: 100));
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    // await Future.delayed(...)
    // _controller.add(msg)
    if (failSend) {
      return Future.delayed(Duration(milliseconds: 200), () => throw Exception('Send failed'));
    }
    await Future.delayed(Duration(milliseconds: 200));
    _controller.sink.add(msg);
  }

   Stream<String> get messageStream => _controller.stream;
  void dispose() {
    _controller.close();
  }
}
