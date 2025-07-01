import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/counter_app.dart';

void main() {
  testWidgets('Counter starts at zero', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    expect(find.text('0'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Counter App'), findsOneWidget);
  });

  testWidgets('Counter increments correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('Counter decrements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('-1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('-2'), findsOneWidget);
  });

  testWidgets('Counter resets correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    // Increment a few times
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    // Reset
    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('Counter handles negative values correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    // Decrement to negative
    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.remove));
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('-3'), findsOneWidget);

    // Increment back to positive
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('Counter has proper layout structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Counter App'), findsOneWidget);
    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(2));
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.remove), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Counter displays large number correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: CounterApp()));

    // Increment many times
    for (int i = 0; i < 10; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }

    expect(find.text('10'), findsOneWidget);
  });
}
