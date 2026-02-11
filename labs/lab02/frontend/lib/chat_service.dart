import 'dart:async';

/// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// When `failSend` is `true`, sending messages throws an error (used in tests)
  bool failSend = false;

  ChatService();

  /// Simulate connection (can be expanded later)
  Future<void> connect() async {
    // Имитируем подключение, можно задержку добавить при необходимости
    await Future.delayed(Duration(milliseconds: 10));
  }

  /// Sends a message through the stream (simulates backend logic)
  Future<void> sendMessage(String msg) async {
    await Future.delayed(Duration(milliseconds: 10)); // Имитируем задержку

    if (failSend) {
      throw Exception('Send failed');
    }

    _controller.add(msg);
  }

  /// Stream of incoming messages (used by UI or listeners)
  Stream<String> get messageStream => _controller.stream;
}
