import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/home/presentation/widgets/weekly_goal_widget.dart';

void main() {
  testWidgets('WeeklyGoalWidget displays correct info', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: WeeklyGoalWidget(completedDays: 3, targetDays: 5),
      ),
    ));

    expect(find.text('Meta Semanal'), findsOneWidget);
    expect(find.text('3 / 5 treinos'), findsOneWidget);
    expect(find.text('Continue firme! Faltam 2 treinos.'), findsOneWidget);
  });
}
