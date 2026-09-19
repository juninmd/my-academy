import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_summary_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

import '../providers/workout_provider_test.mocks.dart';

void main() {
  testWidgets('WorkoutSummaryPage displays summary', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: WorkoutSummaryPage(
            groupId: 1,
            duration: Duration(minutes: 60),
            sessionLogs: {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(); // Animation

    expect(find.text('Treino Concluído!'), findsOneWidget);
    expect(find.text('60m 0s'), findsOneWidget);
  });

  testWidgets('saving the session refreshes the dashboard summary', (
    tester,
  ) async {
    final repository = MockWorkoutRepository();
    when(
      repository.saveWorkoutSession(any, any, any),
    ).thenAnswer((_) async => const Right(unit));
    var summaryLoads = 0;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder:
              (_, _) => const WorkoutSummaryPage(
                groupId: 1,
                duration: Duration(minutes: 1),
                sessionLogs: {},
              ),
        ),
        GoRoute(
          path: '/home',
          builder:
              (_, _) => Consumer(
                builder: (_, ref, _) {
                  ref.watch(workoutSummaryProvider);
                  return const Text('home');
                },
              ),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [
        workoutRepositoryProvider.overrideWithValue(repository),
        workoutSummaryProvider.overrideWith((ref) async {
          summaryLoads++;
          return const WorkoutSummaryEntity(counter: 0, hasWorkoutToday: false);
        }),
      ],
    );
    addTearDown(container.dispose);
    // Keeps the provider alive like the dashboard kept in the shell does.
    container.listen(workoutSummaryProvider, (_, _) {});
    await container.read(workoutSummaryProvider.future);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Concluir'));
    await tester.tap(find.text('Concluir'));
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(summaryLoads, 2);
  });
}
