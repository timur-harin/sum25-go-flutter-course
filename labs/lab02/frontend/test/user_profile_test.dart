import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab02_chat/user_profile.dart';
import 'package:lab02_chat/user_service.dart';

class MockUserService extends UserService {
  bool fail = false;
  @override
  Future<Map<String, String>> fetchUser() async {
    if (fail) throw Exception('Failed');
    await Future.delayed(Duration(milliseconds: 10));
    return {'name': 'Timur Harin', 'email': 'timur.flutter@example.com'};
  }
}

void main() {
  testWidgets('renders user profile UI', (WidgetTester tester) async {
    final service = MockUserService();
    await tester.pumpWidget(MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Chat'),
                Tab(text: 'Profile'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Container(),
              UserProfile(userService: service),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(Tab, 'Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Timur Harin'), findsOneWidget);
    expect(find.text('timur.flutter@example.com'), findsOneWidget);
  });

  testWidgets('handles async update', (WidgetTester tester) async {
    final service = MockUserService();
    await tester.pumpWidget(MaterialApp(
      home: UserProfile(userService: service),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Timur Harin'), findsOneWidget);
  });

  testWidgets('shows error state', (WidgetTester tester) async {
    final service = MockUserService()..fail = true;
    await tester.pumpWidget(MaterialApp(
      home: UserProfile(userService: service),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Error loading user profile'), findsOneWidget);
  });
}
