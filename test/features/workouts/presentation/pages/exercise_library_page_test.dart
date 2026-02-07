import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/exercise_library_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';
import 'package:my_academy/core/widgets/common_empty_state.dart';

void main() {
  final exercises = [
    const ExerciseEntity(id: 1, name: 'Bench Press', description: 'Chest exercise'),
    const ExerciseEntity(id: 2, name: 'Squat', description: 'Leg exercise'),
  ];

  testWidgets('ExerciseLibraryPage shows loading state', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exercisesProvider.overrideWith((ref) => Future.delayed(const Duration(seconds: 1), () => [])),
      ],
      child: const MaterialApp(home: ExerciseLibraryPage()),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
  });

  testWidgets('ExerciseLibraryPage shows list of exercises', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exercisesProvider.overrideWith((ref) async => exercises),
      ],
      child: const MaterialApp(home: ExerciseLibraryPage()),
    ));

    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsOneWidget);
    expect(find.text('Squat'), findsOneWidget);
  });

  testWidgets('ExerciseLibraryPage filters exercises', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exercisesProvider.overrideWith((ref) async => exercises),
      ],
      child: const MaterialApp(home: ExerciseLibraryPage()),
    ));

    await tester.pumpAndSettle();

    // Enter search text
    await tester.enterText(find.byType(TextField), 'Squat');
    await tester.pumpAndSettle();

    expect(find.text('Bench Press'), findsNothing);
    // Finds 2: one in TextField, one in list
    expect(find.descendant(of: find.byType(Card), matching: find.text('Squat')), findsOneWidget);
  });

  testWidgets('ExerciseLibraryPage shows empty state when no matches', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        exercisesProvider.overrideWith((ref) async => exercises),
      ],
      child: const MaterialApp(home: ExerciseLibraryPage()),
    ));

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Zumba');
    await tester.pump();

    expect(find.byType(CommonEmptyState), findsOneWidget);
    expect(find.text('Nenhum exercício encontrado'), findsOneWidget);
  });
}
