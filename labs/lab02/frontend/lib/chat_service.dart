import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // Use a StreamController to simulate incoming messages for tests
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  // Simulation flags for connection and send failures
  bool failConnect = false;
  bool failSend = false;
  bool _connected = false;

  ChatService();

  Future<void> connect() async {
    // Simulate connection (for tests)
    await Future.delayed(const Duration(milliseconds: 200));
    if (failConnect) {
      throw Exception('Connection failed');
    }
    _connected = true;
  }

  Future<void> sendMessage(String msg) async {
    // Simulate sending a message (for tests)
    await Future.delayed(const Duration(milliseconds: 100));
    if (failSend) {
      throw Exception('Send failed');
    }
    if (!_connected) {
      throw Exception('Not connected');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // Return stream of incoming messages (for tests)
    return _controller.stream;
  }

  void dispose() {
    _controller.close();
  }
}
