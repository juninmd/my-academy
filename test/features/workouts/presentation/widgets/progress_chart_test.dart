import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/widgets/progress_chart.dart';

void main() {
  testWidgets('ProgressChart renders correctly with data', (WidgetTester tester) async {
    final logs = [
      ExerciseLogEntity(
        id: '1',
        userId: 'u1',
        exerciseId: 1,
        date: DateTime(2023, 1, 1),
        sets: [SetLogEntity(reps: 10, weight: 100)],
      ),
      ExerciseLogEntity(
        id: '2',
        userId: 'u1',
        exerciseId: 1,
        date: DateTime(2023, 1, 2),
        sets: [SetLogEntity(reps: 10, weight: 110)],
      ),
    ];

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: ProgressChart(logs: logs)),
    ));

    expect(find.byType(ProgressChart), findsOneWidget);
  });
}
