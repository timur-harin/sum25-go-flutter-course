import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Use a StreamController to simulate incoming messages for tests
  // TODO: Add simulation flags for connection and send failures
  // TODO: Replace simulation with real backend logic in the future

  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;
  bool _connected = false;

  ChatService();

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _connected = true;
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception('Send failed');
    }
    
    await Future.delayed(const Duration(milliseconds: 50));
    
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }

  bool get isConnected => _connected;

  void dispose() {
    _controller.close();
  }
}
