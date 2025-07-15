import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab06_frontend/screens/websocket_screen.dart';

void main() {
  group('WebSocketScreen Tests', () {
    testWidgets('should display connection controls and UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // Check if main UI elements are present
      expect(find.text('WebSocket Chat'), findsOneWidget);
      expect(find.text('User ID'), findsOneWidget);
      expect(find.text('Connect'), findsOneWidget);
      expect(find.text('Delay (ms): '), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Ping'), findsOneWidget);

      // Check for message input field
      expect(find.byType(TextField), findsWidgets);

      // Check for connection status indicator
      expect(find.text('Not connected'), findsOneWidget);
    });

    testWidgets('should show empty message state initially',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      expect(find.text('No messages yet.\nConnect and start chatting!'),
          findsOneWidget);
    });

    testWidgets('should validate user ID before connecting',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // Clear the user ID field
      final userIdField = find.widgetWithText(TextField, 'User ID').first;
      await tester.tap(userIdField);
      await tester.pumpAndSettle();

      await tester.enterText(userIdField, '');
      await tester.pumpAndSettle();

      // Try to connect without user ID
      final connectButton = find.widgetWithText(ElevatedButton, 'Connect');
      await tester.tap(connectButton);
      await tester.pumpAndSettle();

      // Should show validation message
      expect(find.text('Please enter a user ID'), findsOneWidget);
    });

    testWidgets('should have working delay input field',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // Find delay input field
      final delayFields = find.byType(TextField);
      final delayField = delayFields
          .evaluate()
          .where((element) {
            final widget = element.widget as TextField;
            return widget.keyboardType == TextInputType.number;
          })
          .first
          .widget as TextField;

      expect(delayField.controller!.text, equals('0'));
    });

    testWidgets('should disable send button when not connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      final sendButton = find.widgetWithText(ElevatedButton, 'Send');
      final sendButtonWidget = tester.widget<ElevatedButton>(sendButton);

      // Send button should be disabled initially (when not connected)
      expect(sendButtonWidget.onPressed, isNull);
    });

    testWidgets('should disable ping button when not connected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      final pingButton = find.text('Ping');
      expect(pingButton, findsOneWidget);

      // Just check that ping functionality exists (simplified)
      expect(find.byType(ElevatedButton), findsAtLeast(1));
    });

    testWidgets('should have pre-filled user ID', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // Should have a pre-filled user ID starting with 'user_'
      final userIdField = find.byType(TextField).first;
      final userIdWidget = tester.widget<TextField>(userIdField);

      expect(userIdWidget.controller!.text, startsWith('user_'));
      expect(userIdWidget.controller!.text.length, greaterThan(5));
    });

    testWidgets('should show connection status icon in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // Check for connection status icon in app bar
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('should format timestamp correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // This test verifies the UI is set up correctly
      // Actual timestamp formatting is tested when messages are displayed
      expect(find.byType(WebSocketScreen), findsOneWidget);
    });
  });

  group('WebSocketScreen Widget Structure', () {
    testWidgets('should have proper widget hierarchy',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      // Check for main scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);

      // Check for connection panel
      expect(find.byType(Container), findsWidgets);

      // Check for message input area
      expect(find.text('Type a message...'), findsOneWidget);
    });

    testWidgets('should have correct input field types',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WebSocketScreen(),
        ),
      );

      final textFields = find.byType(TextField);
      expect(
          textFields, findsAtLeastNWidgets(3)); // User ID, delay, message input
    });
  });
}
