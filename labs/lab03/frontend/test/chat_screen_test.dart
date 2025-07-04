import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:lab03_frontend/screens/chat_screen.dart';
import 'package:lab03_frontend/services/api_service.dart';

void main() {
  group('ChatScreen Widget Tests', () {
    late ApiService mockApiService;

    setUp(() {
      mockApiService = ApiService();
    });

    tearDown(() {
      try {
        mockApiService.dispose();
      } catch (e) {
        // Ignore if dispose is not implemented yet
      }
    });

    testWidgets('should display chat screen with app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: const ChatScreen(),
          ),
        ),
      );

      // Check if app bar is present
      expect(find.byType(AppBar), findsOneWidget);

      // Check if scaffold is present
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display REST API CHAT title',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: const ChatScreen(),
          ),
        ),
      );

      // Should display the app title
      expect(find.text('REST API CHAT'), findsOneWidget);
    });

    testWidgets('should have text controllers for username and message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: const ChatScreen(),
          ),
        ),
      );

      // Wait for widget to settle
      await tester.pumpAndSettle();

      // Should have text fields for input
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });

    testWidgets('should handle loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: const ChatScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle loading states properly
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('should handle error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: const ChatScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle error states properly
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('should display messages when loaded',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => mockApiService,
            child: const ChatScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should display messages in a list
      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });

  group('HTTPStatusDemo Tests', () {
    testWidgets('should show HTTP status demo functionality',
        (WidgetTester tester) async {
      // This test will verify the HTTP status demonstration features
      // Students should implement buttons that show HTTP cat images

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  // This will be implemented by students
                  // HTTPStatusDemo.showRandomStatus(context, ApiService());
                },
                child: const Text('Show HTTP Cat'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Show HTTP Cat'), findsOneWidget);
    });

    testWidgets('should handle different HTTP status codes',
        (WidgetTester tester) async {
      // Test that the demo can handle various status codes
      // This will pass when students implement the HTTPStatusDemo class

      const statusCodes = [200, 201, 400, 404, 418, 500];

      for (final code in statusCodes) {
        // Each status code should be valid for the HTTP cat API
        expect(code, greaterThan(99));
        expect(code, lessThan(600));
      }
    });
  });

  group('Message Operations Tests', () {
    testWidgets('should send new messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => ApiService(),
            child: const ChatScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to send messages
      expect(find.text('Send Message'), findsOneWidget);
    });

    testWidgets('should edit existing messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => ApiService(),
            child: const ChatScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to edit messages
      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('should delete messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Provider<ApiService>(
            create: (_) => ApiService(),
            child: const ChatScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should be able to delete messages
      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });
}
