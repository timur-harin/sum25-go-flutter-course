import 'dart:async';

class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false;

  ChatService();

  Future<void> connect() async {
    await Future.delayed(const Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    await Future.delayed(const Duration(milliseconds: 10)); 
    if (failSend) {
      throw Exception('Send failed');
    }
    _controller.add(msg); 
  }

  Stream<String> get messageStream => _controller.stream;
}