import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:field_officer_app/core/widgets/status_badge.dart';
import 'package:field_officer_app/core/widgets/bhoomi_button.dart';
import 'package:field_officer_app/features/auth/login_screen.dart';

void main() {
  testWidgets('StatusBadge renders correct label and icons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              StatusBadge(status: 'PENDING'),
              StatusBadge(status: 'VERIFIED'),
              StatusBadge(status: 'REJECTED'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('VERIFIED'), findsOneWidget);
    expect(find.text('REJECTED'), findsOneWidget);
  });

  testWidgets('BhoomiButton triggers callback and shows text', (WidgetTester tester) async {
    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BhoomiButton(
            text: 'TEST SUBMIT',
            onPressed: () => wasPressed = true,
          ),
        ),
      ),
    );

    expect(find.text('TEST SUBMIT'), findsOneWidget);
    await tester.tap(find.text('TEST SUBMIT'));
    await tester.pump();

    expect(wasPressed, true);
  });

  testWidgets('LoginScreen renders official credentials form', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('BhoomiSetu'), findsOneWidget);
    expect(find.text('Official Login'), findsOneWidget);
    expect(find.text('Official User ID / Email'), findsOneWidget);
    expect(find.text('AUTHENTICATE & ENTER'), findsOneWidget);
  });
}
