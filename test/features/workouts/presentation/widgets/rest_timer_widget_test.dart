import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/rest_timer_widget.dart';

void main() {
  testWidgets('RestTimerWidget displays info and buttons', (tester) async {
    bool skipped = false;
    bool added10 = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestTimerWidget(
            remainingSeconds: 30,
            totalSeconds: 60,
            onAdd10Seconds: () => added10 = true,
            onSkip: () => skipped = true,
          ),
        ),
      ),
    );

    expect(find.text('30'), findsOneWidget); // Checks remainingSeconds display

    await tester.tap(find.byIcon(Icons.skip_next_rounded));
    expect(skipped, true);

    await tester.tap(find.text('+10s'));
    expect(added10, true);
  });
}
