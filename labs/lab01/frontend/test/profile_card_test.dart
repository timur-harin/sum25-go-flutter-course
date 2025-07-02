import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/profile_card.dart';
import 'package:network_image_mock/network_image_mock.dart';

void main() {
  testWidgets('ProfileCard displays user information correctly', (
    WidgetTester tester,
  ) async {
    const name = 'John Doe';
    const email = 'john@example.com';
    const age = 30;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCard(name: name, email: email, age: age),
        ),
      ),
    );

    expect(find.text(name), findsOneWidget);
    expect(find.text(email), findsOneWidget);
    expect(find.text('Age: $age'), findsOneWidget);
    expect(find.byType(Card), findsOneWidget);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('ProfileCard handles empty name correctly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCard(
            name: '',
            email: 'john@example.com',
            age: 30,
          ),
        ),
      ),
    );

    expect(find.text('?'), findsOneWidget);
    expect(find.text('Age: 30'), findsOneWidget);
  });

  testWidgets('ProfileCard shows avatar when URL is provided', (
    WidgetTester tester,
  ) async {
    const avatarUrl =
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg';

    await mockNetworkImagesFor(() async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ProfileCard(
              name: 'John Doe',
              email: 'john@example.com',
              age: 30,
              avatarUrl: avatarUrl,
            ),
          ),
        ),
      );
    });

    // Verify the CircleAvatar is configured with NetworkImage
    final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(circleAvatar.backgroundImage, isA<NetworkImage>());
    expect(circleAvatar.child, isNull);

    // Verify the NetworkImage has the correct URL
    final networkImage = circleAvatar.backgroundImage as NetworkImage;
    expect(networkImage.url, avatarUrl);
  });

  testWidgets('ProfileCard shows initial letter when no avatar URL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCard(
            name: 'John Doe',
            email: 'john@example.com',
            age: 30,
            avatarUrl: null,
          ),
        ),
      ),
    );

    expect(find.text('J'), findsOneWidget);
    final circleAvatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    expect(circleAvatar.backgroundImage, isNull);
    expect(circleAvatar.child, isNotNull);
  });

  testWidgets('ProfileCard has proper styling', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileCard(
            name: 'John Doe',
            email: 'john@example.com',
            age: 30,
          ),
        ),
      ),
    );

    // Check that the name has bold styling
    final nameText = tester.widget<Text>(find.text('John Doe'));
    expect(nameText.style?.fontWeight, FontWeight.bold);
    expect(nameText.style?.fontSize, 24);

    // Check that the email has grey color
    final emailText = tester.widget<Text>(find.text('john@example.com'));
    expect(emailText.style?.color, Colors.grey);
  });
}
