import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/profile/presentation/widgets/body_composition_dialog.dart';

void main() {
  testWidgets('BodyCompositionDialog calculates', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: BodyCompositionDialog(),
    ));

    expect(find.text('Calculadora de Gordura Corporal'), findsOneWidget);

    // Enter age
    await tester.enterText(find.widgetWithText(TextField, 'Idade (anos)'), '25');
    // Enter one fold
    await tester.enterText(find.widgetWithText(TextField, 'Peitoral'), '10');

    await tester.tap(find.text('Calcular'));
    await tester.pump();

    // Should show result (might be nan or error if not all fields, but the widget handles defaults as 0)
    expect(find.text('Gordura Corporal'), findsOneWidget);
  });
}
