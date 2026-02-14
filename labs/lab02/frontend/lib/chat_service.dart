import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  bool failSend = false;
  bool failConnect = false;

  ChatService();

  Future<void> connect() async {
    if (failConnect) {
      // Симуляция ошибки подключения
      await Future.delayed(Duration(milliseconds: 10));
      throw Exception('Connect failed');
    }
    // Симуляция задержки подключения
    await Future.delayed(Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      // Симуляция ошибки отправки
      await Future.delayed(Duration(milliseconds: 10));
      throw Exception('Send failed');
    }
    // Симуляция задержки отправки
    await Future.delayed(Duration(milliseconds: 10));
    // Отправка сообщения в стрим
    _controller.add(msg);
  }

  Stream<String> get messageStream => _controller.stream;
}
