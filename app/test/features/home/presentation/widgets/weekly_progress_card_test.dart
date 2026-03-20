import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_academy/features/home/presentation/widgets/weekly_progress_card.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    await initializeDateFormatting('pt_BR', null);
    SharedPreferences.setMockInitialValues({'weekly_workout_goal': 5});
  });

  testWidgets('WeeklyProgressCard displays correct progress', (tester) async {
    final now = DateTime.now();
    final todayLog = ExerciseLogEntity(
      id: '1',
      userId: 'u1',
      exerciseId: 1,
      date: now,
      sets: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allExerciseLogsProvider.overrideWith(
            (ref) => Future.value([todayLog]),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: WeeklyProgressCard())),
      ),
    );

    // Allow FutureProvider to resolve
    await tester.pump();

    // Expect to see "1/5" (1 workout, goal 5 from mock prefs)
    expect(find.text('1/5'), findsOneWidget);
    expect(find.text('Meta Semanal'), findsOneWidget);
    expect(find.text('Faltam 4 treinos'), findsOneWidget);
  });

  testWidgets('WeeklyProgressCard shows completion message', (tester) async {
    SharedPreferences.setMockInitialValues({'weekly_workout_goal': 1});

    final now = DateTime.now();
    final todayLog = ExerciseLogEntity(
      id: '1',
      userId: 'u1',
      exerciseId: 1,
      date: now,
      sets: const [],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          allExerciseLogsProvider.overrideWith(
            (ref) => Future.value([todayLog]),
          ),
        ],
        child: const MaterialApp(home: Scaffold(body: WeeklyProgressCard())),
      ),
    );

    // Allow FutureProvider to resolve
    await tester.pump();

    // Expect to see "1/1"
    expect(find.text('1/1'), findsOneWidget);
    expect(find.text('Objetivo Concluído! 🎉'), findsOneWidget);
  });
}
