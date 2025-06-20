import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/counter_app.dart';

void main() {
  testWidgets('Counter increments correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Counter decrements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    expect(find.text('0'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('-1'), findsOneWidget);
  });

  testWidgets('Counter resets correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });
}
