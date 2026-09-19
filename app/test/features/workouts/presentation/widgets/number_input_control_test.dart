import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/number_input_control.dart';

void main() {
  testWidgets('NumberInputControl updates value', (tester) async {
    int value = 10;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumberInputControl(
            value: value,
            onChanged: (v) => value = v,
            label: 'Label',
          ),
        ),
      ),
    );

    expect(find.text('Label'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(value, 11);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumberInputControl(
            value: value,
            onChanged: (v) => value = v,
            label: 'Label',
          ),
        ),
      ),
    );
    expect(find.text('11'), findsOneWidget);
  });

  testWidgets('weight control accepts fractional plate loads', (tester) async {
    double value = 20;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NumberInputControl(
            value: value,
            step: 2.5,
            onChanged: (v) => value = v,
            label: 'Carga',
          ),
        ),
      ),
    );

    expect(find.text('20'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    expect(value, 22.5);

    await tester.enterText(find.byType(TextField), '17,25');
    expect(value, 17.25);

    // Typing past the limit must not bypass the +/- bounds.
    await tester.enterText(find.byType(TextField), '5000');
    expect(value, 17.25);
  });
}
