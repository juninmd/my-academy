import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/presentation/widgets/workout_card.dart';

void main() {
  testWidgets('WorkoutCard displays info', (tester) async {
    const workout = WorkoutEntity(
      id: 1,
      exerciseId: 1,
      exercise: ExerciseEntity(id: 1, name: 'Bench Press', image: null),
      series: [],
    );

    await tester.pumpWidget(MaterialApp(
      home: WorkoutCard(
        workout: workout,
        onTap: () {},
        onLongPress: () {},
      ),
    ));

    expect(find.text('Bench Press'), findsOneWidget);
  });
}
