import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/one_rep_max_display.dart';

void main() {
  testWidgets('OneRepMaxDisplay shows estimated 1RM', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: OneRepMaxDisplay(weight: 100, reps: 5),
    ));

    // 100 * (1 + 5/30) = 100 * 1.166 = 116.6 -> 117
    expect(find.text('1RM: ~117 kg'), findsOneWidget);
  });

  testWidgets('OneRepMaxDisplay hides when 0', (tester) async {
     await tester.pumpWidget(const MaterialApp(
      home: OneRepMaxDisplay(weight: 0, reps: 0),
    ));
    expect(find.byType(Container), findsNothing);
  });
}
