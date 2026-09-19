import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/workout_series_dialog.dart';

void main() {
  testWidgets('WorkoutSeriesDialog collects data', (tester) async {
    int? r, t;
    double? w;
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
    await tester.enterText(
      find.widgetWithText(TextField, 'Carga (kg)'),
      '22,5',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Descanso (s)'),
      '90',
    );

    await tester.tap(find.text('Adicionar'));
    await tester.pumpAndSettle();

    expect(r, 10);
    expect(w, 22.5);
    expect(t, 90);
  });
}
