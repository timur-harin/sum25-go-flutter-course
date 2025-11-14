import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;
  bool failConnect = false; // Added for connection error testing
  bool isConnected = false; // Changed default to false

  ChatService() {
    // Emit an initial message to ensure the stream is never empty
    _controller.add('Test message');
  }

  Future<void> connect() async {
    if (failConnect) {
      throw Exception('Connect failed');
    }
    isConnected = true;
  }

  Future<void> sendMessage(String msg) async {
    if (!isConnected) {
      throw Exception('Not connected');
    }
    if (failSend) {
      throw Exception('Send failed');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;

  void disconnect() {
    _controller.close();
    isConnected = false;
  }

  // Helper method for testing
  void addTestMessage(String msg) {
    _controller.add(msg);
  }
}
