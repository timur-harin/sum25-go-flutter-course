import 'package:flutter_test/flutter_test.dart';
import 'package:lab02_chat/chat_service.dart';
import 'dart:async';

class MockChatService extends ChatService {
  final List<String> _bufferedMessages = []; // Добавляем буфер сообщений
  final StreamController<String> _controller = 
      StreamController<String>.broadcast();
  
  bool failSend = false;

  @override
  Stream<String> get messageStream {
    // Реализуем ретрансляцию буферизированных сообщений
    Stream<String> replayAndLive() async* {
      for (var msg in _bufferedMessages) {
        yield msg;
      }
      yield* _controller.stream;
    }
    return replayAndLive().asBroadcastStream();
  }

  @override
  Future<void> connect() async {}

  @override
  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    _bufferedMessages.add(msg); // Сохраняем сообщение в буфер
    _controller.add(msg); // Отправляем в поток
  }
}

void main() {
  test('emits messages on stream', () async {
    final service = MockChatService();
    final messages = <String>[];
    service.messageStream.listen(messages.add);
    await service.sendMessage('hello');
    await Future.delayed(Duration(milliseconds: 10));
    expect(messages, contains('hello'));
  });

  test('sends message and receives confirmation', () async {
    final service = MockChatService();
    final future = expectLater(service.messageStream, emits('test'));
    await service.sendMessage('test');
    await future;
  });

  test('handles connection errors', () async {
    final service = MockChatService()..failSend = true;
    expect(() => service.sendMessage('fail'), throwsException);
  });
}