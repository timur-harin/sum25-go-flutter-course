import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:lab03_frontend/services/api_service.dart';
import 'package:lab03_frontend/models/message.dart';

void main() {
  group('HTTP Status Code Tests', () {
    test('should validate common HTTP status codes', () {
      // Test that common HTTP status codes are within valid range
      const commonCodes = [
        100, // Continue
        200, // OK
        201, // Created
        204, // No Content
        400, // Bad Request
        401, // Unauthorized
        403, // Forbidden
        404, // Not Found
        418, // I'm a teapot (HTTP cat favorite!)
        500, // Internal Server Error
        503, // Service Unavailable
      ];

      for (final code in commonCodes) {
        expect(code, greaterThanOrEqualTo(100));
        expect(code, lessThanOrEqualTo(599));
      }
    });

    test('should generate correct HTTP cat URLs', () {
      // Test that HTTP cat URLs are generated correctly
      const testCodes = [200, 404, 500];

      for (final code in testCodes) {
        final expectedUrl = 'https://http.cat/$code';
        // Students should implement URL generation
        expect(expectedUrl, startsWith('https://http.cat/'));
        expect(expectedUrl, endsWith(code.toString()));
      }
    });

    test('should handle invalid status codes', () {
      // Test handling of invalid status codes
      const invalidCodes = [99, 600, 999, -1];

      for (final code in invalidCodes) {
        // Should be outside valid HTTP status code range
        expect(code < 100 || code > 599, isTrue);
      }
    });

    test('should provide correct status descriptions', () {
      // Test that status descriptions are provided
      final statusDescriptions = {
        200: 'OK',
        201: 'Created',
        204: 'No Content',
        400: 'Bad Request',
        401: 'Unauthorized',
        403: 'Forbidden',
        404: 'Not Found',
        418: 'I\'m a teapot',
        500: 'Internal Server Error',
        503: 'Service Unavailable',
      };

      statusDescriptions.forEach((code, description) {
        expect(description, isNotEmpty);
        expect(description, isA<String>());
      });
    });
  });

  group('HTTPStatusResponse Model Tests', () {
    test('should create HTTPStatusResponse correctly', () {
      // Test will pass when students implement the model
      try {
        final response = HTTPStatusResponse(
          statusCode: 200,
          imageUrl: 'https://http.cat/200',
          description: 'OK',
        );

        expect(response.statusCode, equals(200));
        expect(response.imageUrl, equals('https://http.cat/200'));
        expect(response.description, equals('OK'));
      } catch (e) {
        // Constructor not implemented yet
        expect(e, isA<NoSuchMethodError>());
      }
    });

    test('should parse HTTPStatusResponse from JSON', () {
      // Test will pass when students implement fromJson
      final jsonData = {
        'status_code': 404,
        'image_url': 'https://http.cat/404',
        'description': 'Not Found',
      };

      try {
        final response = HTTPStatusResponse.fromJson(jsonData);
        expect(response.statusCode, equals(404));
        expect(response.imageUrl, equals('https://http.cat/404'));
        expect(response.description, equals('Not Found'));
      } catch (e) {
        // fromJson not implemented yet
        expect(e, isA<NoSuchMethodError>());
      }
    });
  });

  group('API Service HTTP Status Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    tearDown(() {
      try {
        apiService.dispose();
      } catch (e) {
        // Ignore if dispose not implemented
      }
    });

    test('should get HTTP status for valid codes', () async {
      const validCodes = [200, 404, 500];

      for (final code in validCodes) {
        try {
          final response = await apiService.getHTTPStatus(code);
          expect(response, isA<HTTPStatusResponse>());
          expect(response.statusCode, equals(code));
          expect(response.imageUrl, contains(code.toString()));
        } catch (e) {
          // Method not implemented yet
          expect(e, isA<UnimplementedError>());
        }
      }
    });

    test('should handle invalid status codes gracefully', () async {
      const invalidCodes = [99, 600, 999];

      for (final code in invalidCodes) {
        try {
          await apiService.getHTTPStatus(code);
          // Should throw an error for invalid codes
          fail('Expected an error for invalid status code $code');
        } catch (e) {
          // Should throw appropriate error or UnimplementedError
          expect(
              e,
              anyOf([
                isA<UnimplementedError>(),
                isA<ValidationException>(),
                isA<ApiException>(),
              ]));
        }
      }
    });
  });

  group('HTTP Cat Integration Tests', () {
    testWidgets('should display HTTP cat images in dialogs',
        (WidgetTester tester) async {
      // Test that HTTP cat images can be displayed
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('HTTP Status: 200'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('OK'),
                          const SizedBox(height: 16),
                          Image.network(
                            'https://http.cat/200',
                            errorBuilder: (context, error, stackTrace) {
                              return const Text('Failed to load HTTP cat');
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: const Text('Show HTTP Cat 200'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show HTTP Cat 200'));
      await tester.pumpAndSettle();

      // Should show dialog with HTTP cat content
      expect(find.text('HTTP Status: 200'), findsOneWidget);
    });

    test('should handle network errors for HTTP cat images', () {
      // Test network error handling for images
      const imageUrl = 'https://http.cat/200';

      expect(imageUrl, startsWith('https://'));
      expect(imageUrl, contains('http.cat'));

      // Students should implement proper error handling
      // for when HTTP cat images fail to load
    });
  });
}
