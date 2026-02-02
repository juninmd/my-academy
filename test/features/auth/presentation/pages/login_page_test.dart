import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/pages/login_page.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<UserEntity?> build() async => null;
}

void main() {
  testWidgets('LoginPage renders correctly', (WidgetTester tester) async {
    // Set a larger surface size to ensure all widgets are rendered
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    // Cleanup on tearDown
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
        ],
        child: const MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    // Use pump with duration instead of pumpAndSettle because Swiper has infinite animation
    await tester.pump(const Duration(seconds: 1));

    // Verify Title
    expect(find.text('MY ACADEMY'), findsOneWidget);
    expect(find.text('Evolua todos os dias.'), findsOneWidget);

    // Verify Login Button
    expect(find.text('Entrar com Google'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
