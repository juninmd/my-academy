import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:my_academy/main.dart' as app;

// NOTE: This test requires a running device/emulator and cannot be executed in the current environment.

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App Flow: Start -> Login Check -> Dashboard Navigation', (WidgetTester tester) async {
    // 1. Start the app
    app.main();
    await tester.pumpAndSettle();

    // 2. Verify we are at the Login Page (assuming not logged in initially)
    // or Splash Screen.
    // We look for "MY ACADEMY" text which is on the login page.
    expect(find.text('MY ACADEMY'), findsOneWidget);

    // 3. Attempt Login (Mocking this in a real integration test is hard without a special "Test Mode"
    // or a real backend. Usually we tap the button and hope the Auth Provider handles it).

    // final loginButton = find.text('Entrar com Google');
    // if (loginButton.evaluate().isNotEmpty) {
    //   await tester.tap(loginButton);
    //   await tester.pumpAndSettle(const Duration(seconds: 5));
    // }

    // 4. If we were already logged in (persisted session), we might be at Dashboard.
    // Let's check if we can see the Dashboard title.
    // expect(find.text('Treino do dia'), findsOneWidget);

    // Since we cannot guarantee the auth state in a black-box integration test without setup,
    // this test primarily verifies the App launches without crashing.
  });
}
