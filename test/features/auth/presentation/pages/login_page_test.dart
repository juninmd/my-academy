import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/presentation/pages/login_page.dart';

// Mocking the Auth State is complex without generating mocks,
// so we will test the UI elements that are static or always present.
// For a deep interaction test, we would need to mock the AuthNotifier.

void main() {
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Verify Title
    expect(find.text('MY ACADEMY'), findsOneWidget);
    expect(find.text('Evolua todos os dias.'), findsOneWidget);

    // Verify Login Button
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
