import 'dart:async';

import 'package:flutter/gestures.dart';

// ChatService handles chat logic and backend communication
class ChatService {

  // StreamController to simulate incoming messages for tests
  final StreamController<String> _controller = StreamController<String>.broadcast();

  // Simulation flag for send failures
  bool failSend = false;

  // Simulation flag for connection
  bool failConnect = false;

  ChatService();

  Future<void> connect() async {
    // Connection simulation
    if (failConnect) {
      throw Exception('Connection failed');
    }
    await Future.delayed(Duration(milliseconds: 10));
  }

  Future<void> sendMessage(String msg) async {
    // Simulation of sending a message
    if (failSend) {
      throw Exception('Send failed');
    }
    await Future.delayed(Duration(microseconds: 5));
    _controller.add(msg);
  }

  Stream<String> get messageStream {
    // Returning stream of incoming messages
    return _controller.stream;
  }
}

