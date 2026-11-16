import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/core/theme/pulse_tokens.dart';
import 'package:my_academy/core/widgets/pulse/pressable.dart';
import 'package:my_academy/core/widgets/pulse/pulse_card.dart';
import 'package:my_academy/core/widgets/pulse/pulse_entrance.dart';
import 'package:my_academy/core/widgets/pulse/pulse_line.dart';
import 'package:my_academy/core/widgets/pulse/pulse_ring.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('PulseRing animates to the clamped value', (tester) async {
    await tester.pumpWidget(
      _wrap(const PulseRing(value: 1.7, child: Text('7'))),
    );
    await tester.pumpAndSettle();

    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(PulseRing),
        matching: find.byType(CustomPaint),
      ),
    );
    expect((paint.painter! as PulseRingPainter).progress, 1);
    expect(find.text('7'), findsOneWidget);
  });

  test('PulseRingPainter repaints only when something changes', () {
    const a = PulseRingPainter(
      progress: .5,
      stroke: 8,
      color: PulseColors.volt,
      track: PulseColors.graphite,
    );
    const b = PulseRingPainter(
      progress: .6,
      stroke: 8,
      color: PulseColors.volt,
      track: PulseColors.graphite,
    );
    expect(a.shouldRepaint(a), isFalse);
    expect(b.shouldRepaint(a), isTrue);
  });

  testWidgets('Pressable shrinks while held and fires onTap', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(Pressable(onTap: () => taps++, child: const Text('Go'))),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Go')),
    );
    await tester.pump(PulseMotion.press);
    expect(
      tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
      0.96,
    );

    await gesture.up();
    await tester.pumpAndSettle();
    expect(taps, 1);
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('Pressable without onTap stays still', (tester) async {
    await tester.pumpWidget(_wrap(const Pressable(child: Text('Idle'))));
    await tester.tap(find.text('Idle'));
    await tester.pump();
    expect(tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale, 1);
  });

  testWidgets('PulseCard is tappable only with onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            const PulseCard(child: Text('Static')),
            PulseCard(onTap: () => tapped = true, child: const Text('Tap')),
          ],
        ),
      ),
    );
    expect(find.byType(Pressable), findsOneWidget);
    await tester.tap(find.text('Tap'));
    await tester.pumpAndSettle();
    expect(tapped, isTrue);
  });

  testWidgets('PulseSectionLabel upper-cases and shows trailing', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(const PulseSectionLabel('Seus planos', trailing: Text('ver'))),
    );
    expect(find.text('SEUS PLANOS'), findsOneWidget);
    expect(find.text('ver'), findsOneWidget);
  });

  testWidgets('pulseIn ends fully visible', (tester) async {
    await tester.pumpWidget(_wrap(const Text('Oi').pulseIn(3)));
    await tester.pumpAndSettle();
    expect(find.text('Oi'), findsOneWidget);
  });

  testWidgets('PulseLine draws to completion', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const SizedBox(
          width: 200,
          height: 60,
          child: PulseLine(color: PulseColors.volt),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(PulseLine),
        matching: find.byType(CustomPaint),
      ),
    );
    final painter = paint.painter! as PulseLinePainter;
    expect(painter.progress, 1);
    expect(painter.shouldRepaint(painter), isFalse);
  });
}
