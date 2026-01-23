import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_create_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';

class FakeWorkoutCreateNotifier extends WorkoutCreateNotifier {
  @override
  WorkoutGroupEntity build() => const WorkoutGroupEntity(name: '', userId: 'u1', workouts: []);

  @override
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  @override
  Future<void> saveGroup(String userId) async {}

  @override
  void addWorkout(ExerciseEntity exercise, int reps, int weight, int rest) {}
}

void main() {
  testWidgets('WorkoutCreatePage displays exercises', (tester) async {
    const exercise = ExerciseEntity(id: 1, name: 'Bench Press', image: null);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        exercisesProvider.overrideWith((ref) async => [exercise]),
        workoutCreateNotifierProvider.overrideWith(FakeWorkoutCreateNotifier.new),
      ],
      child: const MaterialApp(
        home: WorkoutCreatePage(),
      ),
    ));
    await tester.pump();

    expect(find.text('Novo Treino'), findsOneWidget);
    expect(find.text('Bench Press'), findsOneWidget);
  });
}
