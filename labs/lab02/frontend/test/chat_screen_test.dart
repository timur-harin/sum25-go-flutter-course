import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:lab02_chat/chat_screen.dart';
import 'package:lab02_chat/chat_service.dart';
import 'dart:async';

class MockChatService extends ChatService {
  final _controller = StreamController<String>.broadcast();
  bool failConnect = false;
  bool failSend = false;

  @override
  Stream<String> get messageStream => _controller.stream;

  @override
  Future<void> connect() async {
    if (failConnect) throw Exception('Connect failed');
    await Future.delayed(Duration(milliseconds: 10));
  }

  @override
  Future<void> sendMessage(String msg) async {
    if (failSend) throw Exception('Send failed');
    await Future.delayed(Duration(milliseconds: 10));
    _controller.add(msg);
  }

  void addMessage(String msg) {
    _controller.add(msg);
  }
}

void main() {
  group('ChatScreen', () {
    testWidgets('renders chat UI and reacts to stream', (
      WidgetTester tester,
    ) async {
      final mockService = MockChatService();
      await tester.pumpWidget(MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Lab 02 Chat'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Chat'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ChatScreen(chatService: mockService),
                Container(),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      // Ensure Chat tab is selected
      await tester.tap(find.widgetWithText(Tab, 'Chat'));
      await tester.pumpAndSettle();

      // Wait for connection
      await tester.pumpAndSettle();

      // Should show chat UI
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Lab 02 Chat'),
        ),
        findsOneWidget,
      );
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);

      // Add message to stream (use a unique message)
      mockService.addMessage('Hello from stream!');
      await tester.pump();
      await tester.pump(); // Additional pump to ensure UI updates

      // Should show message in UI
      expect(find.text('Hello from stream!'), findsOneWidget);
    });

    testWidgets('handles user input and sending', (WidgetTester tester) async {
      final mockService = MockChatService();
      await tester.pumpWidget(MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Lab 02 Chat'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Chat'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ChatScreen(chatService: mockService),
                Container(),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Tab, 'Chat'));
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(find.byType(TextField), 'Test message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Should show sent message
      expect(find.text('Test message'), findsOneWidget);

      // Text field should be cleared
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });

    testWidgets('shows loading and error states', (WidgetTester tester) async {
      final mockService = MockChatService()..failConnect = true;
      await tester.pumpWidget(MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Lab 02 Chat'),
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Chat'),
                  Tab(text: 'Profile'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ChatScreen(chatService: mockService),
                Container(),
              ],
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Tab, 'Chat'));
      await tester.pumpAndSettle();

      // Should show error after failed connection
      expect(find.textContaining('Connection error'), findsOneWidget);
    });
  });
}
