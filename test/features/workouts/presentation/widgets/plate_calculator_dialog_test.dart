import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/profile/presentation/providers/settings_provider.dart';
import 'package:my_academy/features/workouts/presentation/widgets/plate_calculator_dialog.dart';

void main() {
  // Mock SettingsProvider if needed, but for now we can override it with a simple provider
  // Since we don't have the full SettingsProvider implementation file in context,
  // we will try to rely on default values or basic override if possible.
  // However, PlateCalculatorDialog reads `ref.read(settingsProvider).barWeight`.
  // We need to mock this behavior.

  testWidgets('PlateCalculatorDialog calculates correctly for 100kg target and 20kg bar', (WidgetTester tester) async {
    // Override the settings provider to return a fixed bar weight if it's not provided in constructor
    // Note: Since I don't have the SettingsProvider implementation handy to mock properly with Mockito
    // in this specific snippet without seeing the provider definition, I will assume the dialog
    // handles the case where I pass the barWeight in the constructor (which it does).

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
    // Plates for 40: 25 (rem 15) -> 10 (rem 5) -> 5 (rem 0).
    // So: 1x25, 1x10, 1x5.

    expect(find.text('Peso por lado: 40.00 kg'), findsOneWidget);
    expect(find.text('25.0 kg'), findsOneWidget);
    expect(find.text('10.0 kg'), findsOneWidget);
    expect(find.text('5.0 kg'), findsOneWidget);
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
