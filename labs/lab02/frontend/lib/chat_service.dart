import 'dart:async';

import 'package:flutter/material.dart';

// ChatService handles chat logic and backend communication
class ChatService {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();
  bool failSend = false; // From chat service test
  bool failConnect = false; // From chat service test

  ChatService();

  Future<void> connect() async {
    if (failConnect) {
      throw Exception("Connect failed"); // From chat service test
    }

    await Future.delayed(Durations.short2); // for tests
  }

  Future<void> sendMessage(String msg) async {
    if (failSend) {
      throw Exception("Send failed"); // From chat service test
    }

    await Future.delayed(Durations.short1); // for tests
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    return _controller.stream;
  }
}
