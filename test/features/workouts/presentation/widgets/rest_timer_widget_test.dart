import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/rest_timer_widget.dart';

void main() {
  testWidgets('RestTimerWidget displays info and buttons', (tester) async {
    bool skipped = false;
    bool added = false;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: RestTimerWidget(
          remainingSeconds: 30,
          totalSeconds: 60,
          onAdd10Seconds: () => added = true,
          onSkip: () => skipped = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.text('30s'), findsOneWidget);
    expect(find.text('Vamos!'), findsOneWidget);

    await tester.tap(find.text('Vamos!'));
    expect(skipped, true);

    await tester.tap(find.byIcon(Icons.add_circle_outline));
    expect(added, true);
  });
}
