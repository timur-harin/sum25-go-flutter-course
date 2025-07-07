import 'dart:async';

/// ChatService handles chat logic and backend communication
class ChatService {
  /// Controller for broadcasting incoming messages
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Buffer to store sent messages for replay
  final List<String> _bufferedMessages = [];

  /// Flag to simulate send failures in tests
  bool failSend = false;

  ChatService();

  /// Simulates establishing a connection (can be awaited if needed)
  Future<void> connect() async {
    // Simulate a connection delay
    await Future.delayed(Duration(milliseconds: 10));
  }

  /// Sends a message or throws if failure is simulated
  Future<void> sendMessage(String msg) async {
    // Simulate send failure
    if (failSend) throw Exception('Send failed');
    // Buffer the message for future listeners
    _bufferedMessages.add(msg);
    // Add the message to the live stream
    _controller.add(msg);
  }

  /// Stream of incoming messages, replays past messages on new subscriptions
  Stream<String> get messageStream {
    // Use an async generator to first replay buffered messages, then yield live ones
    Stream<String> replayAndLive() async* {
      for (var msg in _bufferedMessages) {
        yield msg;
      }
      yield* _controller.stream;
    }

    // Convert to broadcast so multiple listeners can subscribe
    return replayAndLive().asBroadcastStream();
  }

  /// Dispose resources when done
  void dispose() {
    _controller.close();
  }
}
