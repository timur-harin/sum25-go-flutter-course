import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool simulateConnectionFailure = false;
  bool simulateSendFailure = false;

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 5));
    if (simulateConnectionFailure) {
      throw Exception('Connection failed');
    }
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(const Duration(microseconds: 5));
    if (simulateSendFailure) {
      throw Exception('Send failed');
    }
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}

