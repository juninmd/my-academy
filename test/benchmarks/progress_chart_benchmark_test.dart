import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/widgets/progress_chart.dart';

void main() {
  testWidgets('ProgressChart benchmark', (WidgetTester tester) async {
    // 1. Setup Data
    // We create a larger dataset to make the sorting/processing cost noticeable.
    final logs = List.generate(5000, (index) {
      // Use different dates so sorting has to do work
      // Shuffle logic slightly by using modulo
      final dayOffset = (index * 7) % 5000;
      return ExerciseLogEntity(
        id: 'log_$index',
        userId: 'user_1',
        exerciseId: 1,
        date: DateTime.now().subtract(Duration(days: dayOffset)),
        sets: [
          SetLogEntity(reps: 10, weight: 100),
          SetLogEntity(reps: 8, weight: 110),
          SetLogEntity(reps: 5, weight: 120),
        ],
      );
    });

    // 2. Setup Widget
    final rebuildNotifier = ValueNotifier<int>(0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: rebuildNotifier,
            builder: (context, value, child) {
              // Pass the SAME logs list to simulate parent rebuild with same data
              return ProgressChart(logs: logs);
            },
          ),
        ),
      ),
    );

    // 3. Measure
    final stopwatch = Stopwatch()..start();
    const iterations = 50;

    for (int i = 0; i < iterations; i++) {
      rebuildNotifier.value = i;
      await tester.pump();
    }

    stopwatch.stop();
    print('BENCHMARK_RESULT: ${stopwatch.elapsedMilliseconds}ms for $iterations iterations');
    print('BENCHMARK_AVG: ${stopwatch.elapsedMilliseconds / iterations}ms per iteration');
  });
}
