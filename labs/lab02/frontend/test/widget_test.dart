// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lab02_chat/main.dart';

void main() {
  testWidgets('Chat app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that our chat app loads with tab bar.
    expect(find.text('Lab 02 Chat'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap the Profile tab and verify it shows
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    // Should be able to go back to Chat tab
    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    // Chat tab should be active
    expect(find.text('Chat'), findsOneWidget);
  });
}
