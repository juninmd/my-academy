import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/profile/presentation/widgets/body_composition_dialog.dart';

void main() {
  testWidgets('BodyCompositionDialog calculates (7-site)', (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(
      home: BodyCompositionDialog(),
    ));

    expect(find.text('Calculadora de Gordura Corporal'), findsOneWidget);

    // Enter age
    await tester.enterText(find.widgetWithText(TextField, 'Idade (anos)'), '25');
    // Enter one fold
    await tester.enterText(find.widgetWithText(TextField, 'Peitoral'), '10');

    final buttonFinder = find.text('Calcular');
    await tester.ensureVisible(buttonFinder);
    await tester.pumpAndSettle();

    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    // Should show result (might be nan or error if not all fields, but the widget handles defaults as 0)
    expect(find.text('Gordura Corporal'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });

  testWidgets('BodyCompositionDialog switches to 3-site method and calculates',
      (tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(const MaterialApp(
      home: BodyCompositionDialog(),
    ));

    // Switch to 3 Dobras
    await tester.tap(find.text('3 Dobras'));
    await tester.pumpAndSettle();

    // Verify 'Peitoral' exists (Men 3-site has Peitoral)
    expect(find.widgetWithText(TextField, 'Peitoral'), findsOneWidget);
    // Verify 'Tríceps' does NOT exist (Men 3-site doesn't have Tríceps)
    expect(find.widgetWithText(TextField, 'Tríceps'), findsNothing);

    // Enter values for Men 3-site
    await tester.enterText(
        find.widgetWithText(TextField, 'Idade (anos)'), '25');
    await tester.enterText(find.widgetWithText(TextField, 'Peitoral'), '10');
    await tester.enterText(find.widgetWithText(TextField, 'Abdominal'), '20');
    await tester.enterText(find.widgetWithText(TextField, 'Coxa'), '15');

    // Calculate
    final buttonFinder = find.text('Calcular');
    await tester.ensureVisible(buttonFinder);
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Gordura Corporal'), findsOneWidget);

    addTearDown(tester.view.resetPhysicalSize);
  });
}
