import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_create_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';

class FakeAuthNotifier extends AuthNotifier {
  @override
  Future<UserEntity?> build() async =>
      const UserEntity(id: '1', email: 'test@test.com', name: 'Test User');
}

class FakeWorkoutCreateNotifier extends WorkoutCreateNotifier {
  @override
  WorkoutGroupEntity build() =>
      const WorkoutGroupEntity(name: '', userId: 'u1', workouts: []);

  @override
  void updateName(String name) {
    state = state.copyWith(name: name);
  }

  @override
  Future<void> saveGroup(String userId) async {}

  @override
  void addWorkout(ExerciseEntity exercise, int reps, double weight, int rest) {}
}

void main() {
  testWidgets('WorkoutCreatePage displays exercises in picker', (tester) async {
    const exercise = ExerciseEntity(id: 1, name: 'Bench Press', image: null);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          exercisesProvider.overrideWith((ref) async => [exercise]),
          workoutCreateNotifierProvider.overrideWith(
            FakeWorkoutCreateNotifier.new,
          ),
          authNotifierProvider.overrideWith(() => FakeAuthNotifier()),
          allExerciseLogsProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: WorkoutCreatePage()),
      ),
    );
    // Initial pump (exercisesProvider future needs to resolve? No, it's async value)
    await tester.pumpAndSettle();

    expect(find.text('Novo Treino'), findsOneWidget);

    // Tap Add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle(); // Wait for sheet animation

    // Now check for exercise
    expect(find.text('Bench Press'), findsOneWidget);
  });
}
