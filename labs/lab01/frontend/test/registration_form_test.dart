import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/registration_form.dart';

void main() {
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

    await tester.enterText(find.byKey(const Key('password')), '12345');
    await tester.tap(find.text('Submit'));
    await tester.pump();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('Registration form submits with valid data', (
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
}