import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_summary_page.dart';

void main() {
  testWidgets('WorkoutSummaryPage displays summary', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: WorkoutSummaryPage(
        duration: Duration(minutes: 60),
        sessionLogs: {},
      ),
    ));
    await tester.pumpAndSettle(); // Animation

    expect(find.text('Treino Concluído!'), findsOneWidget);
    expect(find.text('60m 0s'), findsOneWidget);
  });
}
