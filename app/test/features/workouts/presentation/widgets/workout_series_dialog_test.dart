import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/workout_series_dialog.dart';

void main() {
  testWidgets('WorkoutSeriesDialog collects data', (tester) async {
    int? r, w, t;
    await tester.pumpWidget(
      MaterialApp(
        home: WorkoutSeriesDialog(
          exerciseName: 'Squat',
          onSave: (reps, weight, rest) {
            r = reps;
            w = weight;
            t = rest;
          },
        ),
      ),
    );

    expect(find.text('Configurar Squat'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Repetições'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Carga (kg)'), '100');
    await tester.enterText(
      find.widgetWithText(TextField, 'Descanso (s)'),
      '90',
    );

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(r, 10);
    expect(w, 100);
    expect(t, 90);
  });
}
