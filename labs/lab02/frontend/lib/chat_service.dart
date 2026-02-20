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
    await Future.delayed(const Duration(seconds: 1));
    if (failConnect) {
      throw Exception('Connection failed'); // Simulate connection failure
    }
    _controller.add('Connected to chat server.');
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Simulate sending a message (for tests)
    // await Future.delayed(...)
    // _controller.add(msg)
    await Future.delayed(const Duration(milliseconds: 300));

    if (failSend) {
      throw Exception('Failed to send message.');
    }

    // Add the user's message to the stream
    _controller.add('You: $msg');

    // Simulate a bot response after a delay
    await Future.delayed(const Duration(milliseconds: 500));
    _controller.add('Bot: I received "$msg"');
  }

  Stream<String> get messageStream => _controller.stream;

  // Clean up resources
  void dispose() {
    _controller.close();
  }
}