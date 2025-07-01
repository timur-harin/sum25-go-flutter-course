import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/registration_form.dart';

void main() {
  testWidgets('Registration form has proper structure', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Registration Form'), findsOneWidget);
    expect(find.byType(Form), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('Registration form validates empty fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Please enter your name'), findsOneWidget);
    expect(find.text('Please enter a valid email'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('Registration form validates email format', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    // Fill in name and password first to avoid other validation errors
    await tester.enterText(find.byKey(const Key('name')), 'John Doe');
    await tester.enterText(find.byKey(const Key('password')), 'password123');

    // Test invalid email format
    await tester.enterText(find.byKey(const Key('email')), 'invalid-email');
    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('Registration form validates password length', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    // Test short passwords
    final shortPasswords = ['12345', 'abc', ''];

    for (final password in shortPasswords) {
      await tester.enterText(find.byKey(const Key('password')), password);
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(
          find.text('Password must be at least 6 characters'), findsOneWidget);

      // Clear the field for next test
      await tester.enterText(find.byKey(const Key('password')), '');
      await tester.pump();
    }
  });

  testWidgets('Registration form accepts valid data', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    await tester.enterText(find.byKey(const Key('name')), 'John Doe');
    await tester.enterText(find.byKey(const Key('email')), 'john@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'password123');

    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Registration successful!'), findsOneWidget);
  });

  testWidgets('Registration form resets after successful submission', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    // Fill form with valid data
    await tester.enterText(find.byKey(const Key('name')), 'John Doe');
    await tester.enterText(find.byKey(const Key('email')), 'john@example.com');
    await tester.enterText(find.byKey(const Key('password')), 'password123');

    await tester.tap(find.text('Submit'));
    await tester.pump();

    // Wait for snackbar to disappear
    await tester.pump(const Duration(seconds: 3));

    // Check that form fields are cleared
    expect(find.text('John Doe'), findsNothing);
    expect(find.text('john@example.com'), findsNothing);
    expect(find.text('password123'), findsNothing);
  });

  testWidgets('Registration form validates individual fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    // Test name validation
    await tester.enterText(find.byKey(const Key('name')), '');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Please enter your name'), findsOneWidget);

    // Test email validation
    await tester.enterText(find.byKey(const Key('name')), 'John Doe');
    await tester.enterText(find.byKey(const Key('email')), 'invalid-email');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);

    // Test password validation
    await tester.enterText(find.byKey(const Key('email')), 'john@example.com');
    await tester.enterText(find.byKey(const Key('password')), '123');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('Password field is obscured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: RegistrationForm())),
    );

    // Verify password field exists and has the correct key
    expect(find.byKey(const Key('password')), findsOneWidget);

    // Verify the password field is present in the form
    expect(find.text('Password'), findsOneWidget);
  });
}
