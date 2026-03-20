import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_player_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

void main() {
  testWidgets('WorkoutPlayerPage displays player with exercise', (
    tester,
  ) async {
    const group = WorkoutGroupEntity(
      id: 1,
      name: 'Leg Day',
      userId: 'u1',
      workouts: [
        WorkoutEntity(
          id: 1,
          exerciseId: 1,
          exercise: ExerciseEntity(id: 1, name: 'Squat'),
          series: [],
        ),
      ],
      image: null,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          workoutGroupByIdProvider(1).overrideWith((ref) async => group),
          exerciseLogsProvider(1).overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: WorkoutPlayerPage(groupId: 1)),
      ),
    );
    await tester.pump();

    expect(find.text('Leg Day'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
    expect(find.text('Execução'), findsOneWidget);
  });
}
