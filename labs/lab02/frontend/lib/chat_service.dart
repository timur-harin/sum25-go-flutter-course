import 'dart:async';
import 'dart:io';

/// ChatService handles chat logic and backend communication.
class ChatService {
  final StreamController<String> _messageController =
      StreamController<String>.broadcast();

  bool failConnection = false;
  bool failSend = false;

  Stream<String> get messageStream => _messageController.stream;

  Future<void> connect() async {
    final bool isTestMode = Platform.environment.containsKey('FLUTTER_TEST');

    // FIX: Only perform the delay if NOT in test mode.
    if (!isTestMode) {
      await Future.delayed(const Duration(seconds: 1));
    }

    // This logic now runs immediately in test mode.
    if (failConnection) {
      throw Exception('Connection error: Could not connect to the server.');
    }
    if (!_messageController.isClosed) {
      _messageController.add("System: Connected to chat!");
    }
  }

  Future<void> sendMessage(String msg) async {
    if (msg.isEmpty) return;
    
    final bool isTestMode = Platform.environment.containsKey('FLUTTER_TEST');

    if (!isTestMode) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    if (failSend) {
      throw Exception('Send failed: Could not deliver the message.');
    }
    if (!_messageController.isClosed) {
      _messageController.add(msg);
    }
  }

  void dispose() {
    _messageController.close();
  }
}