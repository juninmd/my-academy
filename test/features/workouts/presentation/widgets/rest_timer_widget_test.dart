import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/rest_timer_widget.dart';

void main() {
  testWidgets('RestTimerWidget displays info and buttons', (tester) async {
    bool skipped = false;
    bool added = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RestTimerWidget(
            remainingSeconds: 30,
            totalSeconds: 60,
            onAdd10Seconds: () => added = true,
            onSkip: () => skipped = true,
          ),
        ),
      ),
    );

    expect(find.text('30s'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);

    await tester.tap(find.text('Pular'));
    expect(skipped, true);

    await tester.tap(find.text('+10'));
    expect(added, true);
  });
}
