import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_details_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

void main() {
  testWidgets('WorkoutDetailsPage displays group info', (tester) async {
    const group = WorkoutGroupEntity(
      id: 1,
      name: 'Leg Day',
      userId: 'u1',
      workouts: [],
      image: null,
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        workoutGroupByIdProvider(1).overrideWith((ref) async => group),
      ],
      child: const MaterialApp(
        home: WorkoutDetailsPage(groupId: 1),
      ),
    ));
    await tester.pump();

    expect(find.text('Leg Day'), findsOneWidget);
    expect(find.text('Nenhum exercício neste treino'), findsOneWidget);
    expect(find.text('Iniciar Treino'), findsOneWidget);
  });
}
