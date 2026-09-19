import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/presentation/widgets/login_background.dart';

Widget _host({required bool reduceMotion}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: const Stack(children: [LoginBackground()]),
  ),
);

void main() {
  testWidgets('animates the backdrop by default', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: false));
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.hasRunningAnimations, isTrue);

    // Paints through a full cycle, including the pulse wrap-around.
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(seconds: 5));
    }
    expect(tester.takeException(), isNull);
  });

  // Accessibility: users who ask for reduced motion get a still image.
  testWidgets('stays still when reduced motion is requested', (tester) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    await tester.pumpAndSettle();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('has no photos and is hidden from screen readers', (
    tester,
  ) async {
    await tester.pumpWidget(_host(reduceMotion: true));
    expect(find.byType(Image), findsNothing);
    expect(
      find.descendant(
        of: find.byType(LoginBackground),
        matching: find.byType(ExcludeSemantics),
      ),
      findsOneWidget,
    );
  });
}
