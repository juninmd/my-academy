import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/exercise_stats_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

void main() {
  testWidgets('ExerciseStatsPage displays exercise info', (tester) async {
    const exercise = ExerciseEntity(
      id: 1,
      name: 'Bench Press',
      image: null,
      tips: ['Tip 1'],
      mistakes: ['Mistake 1'],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        exerciseLogsProvider.overrideWith((ref, id) async => []),
      ],
      child: const MaterialApp(
        home: ExerciseStatsPage(exercise: exercise),
      ),
    ));
    await tester.pump(); // wait for future

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Dicas'), findsOneWidget);
    expect(find.text('Tip 1'), findsOneWidget);
    expect(find.text('Erros Comuns'), findsOneWidget);
    expect(find.text('Mistake 1'), findsOneWidget);
    expect(find.text('Nenhum registro encontrado.'), findsOneWidget);
  });
}
