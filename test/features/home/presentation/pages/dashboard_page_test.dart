import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/presentation/pages/dashboard_page.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('DashboardPage renders static elements and Tools section', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier(
            const UserEntity(id: 'u1', email: 'e', name: 'User')
          )),
          workoutSummaryProvider.overrideWith((ref) async => const WorkoutSummaryEntity(
            counter: 5,
            hasWorkoutToday: false,
          )),
          allExerciseLogsProvider.overrideWith((ref) async => []), // No logs
          exercisesProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify App Bar
    expect(find.text('Treino do dia'), findsOneWidget);

    // Verify Tools Section
    expect(find.text('Ferramentas'), findsOneWidget);

    // Verify Rest Card (Generic because no logs)
    expect(find.text('Descanso Merecido'), findsOneWidget);
  });

  testWidgets('DashboardPage shows Last Workout when resting and logs exist', (WidgetTester tester) async {
    final now = DateTime.now();
    final log = ExerciseLogEntity(
      id: 'l1',
      userId: 'u1',
      exerciseId: 1,
      date: now,
      sets: [SetLogEntity(weight: 100, reps: 5)],
    );
    final exercise = ExerciseEntity(id: 1, name: 'Supino', tips: [], mistakes: []);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier(
            const UserEntity(id: 'u1', email: 'e', name: 'User')
          )),
          workoutSummaryProvider.overrideWith((ref) async => const WorkoutSummaryEntity(
            counter: 5,
            hasWorkoutToday: false,
          )),
          allExerciseLogsProvider.overrideWith((ref) async => [log]),
          exercisesProvider.overrideWith((ref) async => [exercise]),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Should NOT see generic rest card text
    expect(find.text('Descanso Merecido'), findsNothing);

    // Should see Last Workout
    expect(find.text('Último Treino'), findsOneWidget);
    expect(find.text('Supino'), findsOneWidget);
    expect(find.text('100kg'), findsOneWidget);
  });
}
