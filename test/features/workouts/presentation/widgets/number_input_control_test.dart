import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/number_input_control.dart';

void main() {
  testWidgets('NumberInputControl updates value', (tester) async {
    int value = 10;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NumberInputControl(
          value: value,
          onChanged: (v) => value = v,
          label: 'Label',
        ),
      ),
    ));

    expect(find.text('Label'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(value, 11);

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: NumberInputControl(
          value: value,
          onChanged: (v) => value = v,
          label: 'Label',
        ),
      ),
    ));
    expect(find.text('11'), findsOneWidget);
  });
}
