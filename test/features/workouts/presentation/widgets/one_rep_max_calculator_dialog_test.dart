import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/one_rep_max_calculator_dialog.dart';

void main() {
  testWidgets(
    'OneRepMaxCalculatorDialog calculates 1RM correctly using Epley formula',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: OneRepMaxCalculatorDialog()),
      );

      // Verify initial state
      expect(find.text('Calculadora 1RM'), findsOneWidget);
      expect(
        find.text('1RM Estimado'),
        findsNothing,
      ); // Should be hidden initially

      // Input data
      // Weight: 100kg, Reps: 10
      // Epley: 100 * (1 + 10/30) = 100 * (1 + 0.333...) = 133.33...
      await tester.enterText(
        find.widgetWithText(TextField, 'Carga (kg)'),
        '100',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Repetições'),
        '10',
      );
      await tester.pump(); // Rebuild for setState

      // Verify result
      // 133.3 kg
      expect(find.text('133.3 kg'), findsOneWidget);
      expect(find.text('1RM Estimado'), findsOneWidget);

      // Verify percentages table
      // 95% of 133.33 = 126.66... -> 126.7 kg
      expect(find.text('95%'), findsOneWidget);
      expect(find.text('126.7 kg'), findsOneWidget);
    },
  );

  testWidgets('OneRepMaxCalculatorDialog handles invalid input gracefully', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: OneRepMaxCalculatorDialog()),
    );

    await tester.enterText(find.widgetWithText(TextField, 'Carga (kg)'), 'abc');
    await tester.pump();

    expect(find.text('1RM Estimado'), findsNothing);
  });
}
