import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/plate_calculator_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('PlateCalculatorDialog calculates correctly for 100kg target and 20kg bar', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PlateCalculatorDialog(
            targetWeight: 100,
            barWeight: 20,
          ),
        ),
      ),
    );

    // Initial state: Target 100, Bar 20. Side = (100 - 20) / 2 = 40.
    // Plates for 40 using [25, 20, 15, 10, 5, 2.5, 1.25]:
    // 40 / 25 = 1 (rem 15)
    // 15 / 15 = 1 (rem 0)
    // So: 1x25, 1x15.

    expect(find.text('Peso por lado: 40.00 kg'), findsOneWidget);
    expect(find.text('25.0 kg'), findsOneWidget);
    expect(find.text('15.0 kg'), findsOneWidget);
  });

  testWidgets('PlateCalculatorDialog updates calculation on input change', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PlateCalculatorDialog(
            targetWeight: 60,
            barWeight: 20,
          ),
        ),
      ),
    );

    // Initial: (60 - 20)/2 = 20 -> 1x20.
    expect(find.text('Peso por lado: 20.00 kg'), findsOneWidget);
    expect(find.text('20.0 kg'), findsOneWidget);

    // Change target to 70.
    // Find the TextField for target weight (first one).
    final targetField = find.widgetWithText(TextField, 'Peso Total (kg)');
    await tester.enterText(targetField, '70');
    await tester.pump();

    // New: (70 - 20)/2 = 25 -> 1x25.
    expect(find.text('Peso por lado: 25.00 kg'), findsOneWidget);
    expect(find.text('25.0 kg'), findsOneWidget);
    expect(find.text('20.0 kg'), findsNothing);
  });
}
