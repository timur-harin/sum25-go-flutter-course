import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import '../lib/chat_screen.dart';
import '../lib/chat_service.dart';

void main() {
  group('ChatScreen', () {
    testWidgets('renders chat UI and reacts to stream', (
      WidgetTester tester,
    ) async {
      // TODO: Test that chat UI renders and updates with stream
    });
    testWidgets('handles user input and sending', (WidgetTester tester) async {
      // TODO: Test sending a message from input
    });
    testWidgets('shows loading and error states', (WidgetTester tester) async {
      // TODO: Test loading and error UI
    });
  });
}
