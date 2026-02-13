import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

class ChatService {
  late final StreamController<String> _controller;
  final Random _random = Random();
  bool _isConnected = false;
  bool _simulateConnectionFailure = false;
  bool _simulateSendFailure = false;
  bool _simulateRandomFailures = false;
  Timer? _messageSimulator;

  /// Creates ChatService with optional failure simulations
  ChatService({
    bool simulateConnectionFailure = false,
    bool simulateSendFailure = false,
    bool simulateRandomFailures = false,
  }) {
    _simulateConnectionFailure = simulateConnectionFailure;
    _simulateSendFailure = simulateSendFailure;
    _simulateRandomFailures = simulateRandomFailures;
    _controller = StreamController<String>.broadcast();
  }

  /// Simulates connection to chat server
  Future<void> connect() async {
    if (_simulateConnectionFailure) {
      await Future.delayed(const Duration(seconds: 1));
      throw Exception('Simulated connection failure');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _isConnected = true;

    _messageSimulator = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_isConnected) {
        _controller.add('Simulated message ${_random.nextInt(100)}');
      }
    });
  }

  /// Simulates sending a message
  Future<void> sendMessage(String msg) async {
    if (!_isConnected) {
      throw Exception('Not connected to chat');
    }

    if (_simulateSendFailure ||
        (_simulateRandomFailures && _random.nextDouble() > 0.7)) {
      await Future.delayed(const Duration(milliseconds: 300));
      throw Exception('Simulated send failure');
    }

    await Future.delayed(const Duration(milliseconds: 200));
    _controller.add('You: $msg');
  }

  /// Returns the stream of incoming messages
  Stream<String> get messageStream {
    if (!_isConnected) {
      throw Exception('Not connected to chat');
    }
    return _controller.stream;
  }

  /// Disconnects from chat
  Future<void> disconnect() async {
    _messageSimulator?.cancel();
    _isConnected = false;
    // Don't close the stream controller, as it may break test subclasses.
    // await _controller.close();
  }

  /// For testing: simulate incoming message
  @visibleForTesting
  void simulateIncomingMessage(String message) {
    _controller.add(message);
  }
}
