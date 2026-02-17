import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/timer_notifier.dart';
import 'package:my_academy/features/workouts/presentation/widgets/workout_timer.dart';

void main() {
  testWidgets('WorkoutTimer updates UI when notifier changes', (tester) async {
    final notifier = TimerNotifier();

    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: WorkoutTimer(notifier: notifier))),
    );

    // Initial state
    expect(find.text('00:00'), findsOneWidget);

    // Update notifier
    notifier.value = 65;
    await tester.pump(); // Rebuild

    expect(find.text('01:05'), findsOneWidget);

    notifier.dispose();
  });
}
