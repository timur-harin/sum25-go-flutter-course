import 'dart:async';

// ChatService handles chat logic and backend communication
class ChatService {
  // TODO: Add StreamController for incoming messages
  // TODO: Add connection state, error state, etc.

  ChatService();

  Future<void> connect() async {
    // TODO: Connect to backend or mock
  }

  Future<void> sendMessage(String msg) async {
    // TODO: Send message to backend or mock
  }

  Stream<String> get messageStream {
    // TODO: Return stream of incoming messages
    throw UnimplementedError();
  }
}
