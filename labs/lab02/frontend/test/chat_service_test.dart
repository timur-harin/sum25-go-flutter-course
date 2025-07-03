import 'package:flutter_test/flutter_test.dart';
import 'package:lab02_chat/chat_service.dart';
import 'dart:async';

class MockChatService extends ChatService {
  final _controller = StreamController<String>.broadcast();
  bool failSend = false;
  @override
  Stream<String> get messageStream => _controller.stream;
  @override
  Future<void> connect() async {}
  @override
  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    _controller.add(msg);
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
