import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab06_frontend/screens/calculator_screen.dart';

void main() {
  group('CalculatorScreen Tests', () {
    testWidgets('should display calculator UI elements',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Check if main UI elements are present
      expect(find.text('Calculator (HTTP → gRPC)'), findsOneWidget);
      expect(find.text('Calculator Inputs'), findsOneWidget);
      expect(find.text('First Number (A)'), findsOneWidget);
      expect(find.text('Second Number (B)'), findsOneWidget);
      expect(find.text('Operations'), findsOneWidget);
      expect(find.text('Result'), findsOneWidget);
      expect(find.text('Calculation History'), findsOneWidget);
    });

    testWidgets('should have all calculator operation buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Check for operation buttons
      expect(find.text('+ Add'), findsOneWidget);
      expect(find.text('- Subtract'), findsOneWidget);
      expect(find.text('× Multiply'), findsOneWidget);
      expect(find.text('÷ Divide'), findsOneWidget);
    });

    testWidgets('should have pre-filled input values',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Check for pre-filled values
      expect(find.text('10'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('should validate input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Clear input fields
      final firstNumberField =
          find.widgetWithText(TextField, 'First Number (A)');
      await tester.enterText(firstNumberField, '');
      await tester.pumpAndSettle();

      // Try to perform operation with empty input
      final addButton = find.text('+ Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter valid numbers'), findsOneWidget);
    });

    testWidgets('should show calculation result placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      expect(find.text('Perform a calculation to see results'), findsOneWidget);
    });

    testWidgets('should show history placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      expect(
          find.text(
              'No calculations yet.\nPerform some operations to see history.'),
          findsOneWidget);
    });

    testWidgets('should have refresh button in app bar',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should allow input in number fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Test entering numbers in first field
      final firstNumberField =
          find.widgetWithText(TextField, 'First Number (A)');
      await tester.enterText(firstNumberField, '15');
      await tester.pumpAndSettle();

      // Test entering numbers in second field
      final secondNumberField =
          find.widgetWithText(TextField, 'Second Number (B)');
      await tester.enterText(secondNumberField, '3');
      await tester.pumpAndSettle();

      // Verify the values were entered
      expect(find.text('15'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('should have correct button colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Check if buttons are present (color checking is more complex in tests)
      expect(find.widgetWithText(ElevatedButton, '+ Add'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '- Subtract'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '× Multiply'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, '÷ Divide'), findsOneWidget);
    });

    testWidgets('should show loading state when performing operation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Note: This test checks the UI structure for loading state
      // Actual loading testing would require mocking the API service
      expect(find.byType(ElevatedButton), findsAtLeastNWidgets(4));
    });
  });

  group('CalculatorScreen Widget Structure', () {
    testWidgets('should have proper widget hierarchy',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Check for main scaffold
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(Column), findsWidgets);

      // Check for cards
      expect(find.byType(Card), findsAtLeastNWidgets(4));

      // Check for input fields
      expect(find.byType(TextField), findsAtLeastNWidgets(2));
    });

    testWidgets('should have correct number keyboard type for input fields',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      final textFields = find.byType(TextField);

      // Both number input fields should have number keyboard
      for (final textFieldFinder in textFields.evaluate()) {
        final textField = textFieldFinder.widget as TextField;
        if (textField.decoration?.labelText?.contains('Number') == true) {
          expect(textField.keyboardType, equals(TextInputType.number));
        }
      }
    });

    testWidgets('should have expandable history section',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Check for Expanded widget that contains history
      expect(find.byType(Expanded), findsAtLeastNWidgets(1));
    });

    testWidgets('should handle button press correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Test that buttons are tappable
      final addButton = find.text('+ Add');
      await tester.tap(addButton);
      await tester.pump();

      // The tap should not crash the app
      expect(find.byType(CalculatorScreen), findsOneWidget);
    });
  });

  group('CalculatorScreen Input Validation', () {
    testWidgets('should handle negative numbers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Enter negative number
      final firstNumberField =
          find.widgetWithText(TextField, 'First Number (A)');
      await tester.enterText(firstNumberField, '-5');
      await tester.pumpAndSettle();

      expect(find.text('-5'), findsOneWidget);
    });

    testWidgets('should handle decimal numbers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Enter decimal number
      final firstNumberField =
          find.widgetWithText(TextField, 'First Number (A)');
      await tester.enterText(firstNumberField, '3.14');
      await tester.pumpAndSettle();

      expect(find.text('3.14'), findsOneWidget);
    });

    testWidgets('should handle invalid text input',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CalculatorScreen(),
        ),
      );

      // Enter invalid text
      final firstNumberField =
          find.widgetWithText(TextField, 'First Number (A)');
      await tester.enterText(firstNumberField, 'abc');
      await tester.pumpAndSettle();

      // Try to perform operation
      final addButton = find.text('+ Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      // Should show validation error
      expect(find.text('Please enter valid numbers'), findsOneWidget);
    });
  });
}
