import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:lab03_frontend/screens/chat_screen.dart';
import 'package:lab03_frontend/services/api_service.dart';
import 'package:lab03_frontend/main.dart';
import 'package:lab03_frontend/models/message.dart';

void main() {
  group('ChatScreen Widget Tests', () {
    late ApiService mockApiService;

    setUp(() {
      mockApiService = ApiService();
    });

    tearDown(() {
      mockApiService.dispose();
    });

    // Helper function to create mock client
    MockClient _createMockClient() {
      return MockClient((request) async {
        if (request.url.toString() == 'http://localhost:8080/api/messages' &&
            request.method == 'GET') {
          final response = {
            'success': true,
            'data': [
              {
                'id': 1,
                'username': 'testuser',
                'content': 'test message',
                'timestamp': '2024-01-01T00:00:00.000Z'
              }
            ]
          };
          return http.Response(jsonEncode(response), 200);
        }
        if (request.url.toString() == 'http://localhost:8080/api/messages' &&
            request.method == 'POST') {
          final response = {
            'success': true,
            'data': {
              'id': 2,
              'username': 'integrationtest',
              'content': 'Test message from integration test',
              'timestamp': '2024-01-01T00:00:00.000Z'
            }
          };
          return http.Response(jsonEncode(response), 201);
        }
        if (request.url.toString() == 'http://localhost:8080/api/status/200') {
          final response = {
            'success': true,
            'data': {
              'status_code': 200,
              'image_url': 'http://localhost:8080/api/cat/200',
              'description': 'OK'
            }
          };
          return http.Response(jsonEncode(response), 200);
        }
        if (request.url.toString() == 'http://localhost:8080/api/status/404') {
          final response = {
            'success': true,
            'data': {
              'status_code': 404,
              'image_url': 'http://localhost:8080/api/cat/404',
              'description': 'Not Found'
            }
          };
          return http.Response(jsonEncode(response), 200);
        }
        return http.Response('Not Found', 404);
      });
    }

    // MOCK TESTS
    group('Mock Tests', () {
      testWidgets('should display chat screen with proper UI elements',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiService>(
                create: (_) => ApiService(client: _createMockClient()),
                dispose: (_, apiService) => apiService.dispose(),
              ),
              ChangeNotifierProxyProvider<ApiService, ChatProvider>(
                create: (context) => ChatProvider(
                  Provider.of<ApiService>(context, listen: false),
                ),
                update: (context, apiService, previous) =>
                    previous ?? ChatProvider(apiService),
              ),
            ],
            child: const MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Wait for messages to load
        await tester.pumpAndSettle();

        // Should have app bar
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.text('REST API Chat'), findsOneWidget);

        // Should have input fields
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.text('Enter your username'), findsOneWidget);
        expect(find.text('Enter your message'), findsOneWidget);

        // Should have HTTP status buttons
        expect(find.text('200 OK'), findsOneWidget);
        expect(find.text('404 Not Found'), findsOneWidget);
        expect(find.text('500 Error'), findsOneWidget);

        // Should have send button
        expect(find.text('Send'), findsOneWidget);

        // Should have refresh buttons
        expect(find.byIcon(Icons.refresh), findsNWidgets(2)); // App bar + FAB

        // Should have floating action button
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });

      testWidgets('should send message and update UI',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiService>(
                create: (_) => ApiService(client: _createMockClient()),
                dispose: (_, apiService) => apiService.dispose(),
              ),
              ChangeNotifierProxyProvider<ApiService, ChatProvider>(
                create: (context) => ChatProvider(
                  Provider.of<ApiService>(context, listen: false),
                ),
                update: (context, apiService, previous) =>
                    previous ?? ChatProvider(apiService),
              ),
            ],
            child: const MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Wait for initial load
        await tester.pumpAndSettle();

        // Find username and message input fields
        final usernameField = find.byType(TextField).first;
        final messageField = find.byType(TextField).at(1);
        final sendButton = find.text('Send');

        // Enter username and message
        await tester.enterText(usernameField, 'integrationtest');
        await tester.enterText(
            messageField, 'Test message from integration test');
        await tester.pump();

        // Tap send button
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        // Should show success message
        expect(find.byType(SnackBar), findsOneWidget);
      });

      testWidgets('should show HTTP status dialogs when buttons are pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiService>(
                create: (_) => ApiService(client: _createMockClient()),
                dispose: (_, apiService) => apiService.dispose(),
              ),
              ChangeNotifierProxyProvider<ApiService, ChatProvider>(
                create: (context) => ChatProvider(
                  Provider.of<ApiService>(context, listen: false),
                ),
                update: (context, apiService, previous) =>
                    previous ?? ChatProvider(apiService),
              ),
            ],
            child: const MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Wait for initial load
        await tester.pumpAndSettle();

        // Find and tap HTTP status buttons
        final status200Button = find.text('200 OK');
        final status404Button = find.text('404 Not Found');

        expect(status200Button, findsOneWidget);
        expect(status404Button, findsOneWidget);

        // Tap 200 OK button
        await tester.tap(status200Button);
        await tester.pumpAndSettle();

        // Should show dialog with HTTP status
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('HTTP Status: 200'), findsOneWidget);
        expect(find.text('OK'), findsOneWidget);

        // Close dialog
        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // Tap 404 button
        await tester.tap(status404Button);
        await tester.pumpAndSettle();

        // Should show dialog with 404 status
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('HTTP Status: 404'), findsOneWidget);
        expect(find.text('Not Found'), findsOneWidget);
      });

      testWidgets('should display error message when API fails',
          (WidgetTester tester) async {
        // Create a mock client that returns error
        final errorMockClient = MockClient((request) async {
          return http.Response('Server Error', 500);
        });

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiService>(
                create: (_) => ApiService(client: errorMockClient),
                dispose: (_, apiService) => apiService.dispose(),
              ),
              ChangeNotifierProxyProvider<ApiService, ChatProvider>(
                create: (context) => ChatProvider(
                  Provider.of<ApiService>(context, listen: false),
                ),
                update: (context, apiService, previous) =>
                    previous ?? ChatProvider(apiService),
              ),
            ],
            child: const MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Wait for error to appear
        await tester.pumpAndSettle();

        // Should show error widget
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('should display empty state when no messages',
          (WidgetTester tester) async {
        // Create a mock client that returns empty messages
        final emptyMockClient = MockClient((request) async {
          if (request.url.toString() == 'http://localhost:8080/api/messages' &&
              request.method == 'GET') {
            final response = {'success': true, 'data': []};
            return http.Response(jsonEncode(response), 200);
          }
          return http.Response('Not Found', 404);
        });

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<ApiService>(
                create: (_) => ApiService(client: emptyMockClient),
                dispose: (_, apiService) => apiService.dispose(),
              ),
              ChangeNotifierProxyProvider<ApiService, ChatProvider>(
                create: (context) => ChatProvider(
                  Provider.of<ApiService>(context, listen: false),
                ),
                update: (context, apiService, previous) =>
                    previous ?? ChatProvider(apiService),
              ),
            ],
            child: const MaterialApp(
              home: ChatScreen(),
            ),
          ),
        );

        // Wait for messages to load
        await tester.pumpAndSettle();

        // Should show empty state
        expect(find.text('No messages yet'), findsOneWidget);
        expect(find.text('Send your first message to get started!'),
            findsOneWidget);
      });
    });
  });
}
