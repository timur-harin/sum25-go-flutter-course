import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sum25_flutter_frontend/main.dart';

void main() {
  group('CourseApp Widget Tests', () {
    testWidgets('CourseApp should create without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('HomeScreen should display welcome text',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      expect(find.text('Welcome to the Summer 2025 Course!'), findsOneWidget);
      expect(
          find.text(
              'This app demonstrates Go backend + Flutter frontend integration.'),
          findsOneWidget);
    });

    testWidgets('HomeScreen should have About and Test API buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Test API'), findsOneWidget);
    });

    testWidgets('Test API button should show snackbar when pressed',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: CourseApp(),
        ),
      );
      await tester.tap(find.text('Test API'));
      await tester.pump();
      expect(find.text('API integration coming soon!'), findsOneWidget);
    });
  });
}
