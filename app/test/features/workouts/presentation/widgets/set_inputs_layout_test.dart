import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/workout_player/set_inputs_layout.dart';

Widget _row() => const SetInputsLayout(
  children: [
    Expanded(child: SizedBox(key: Key('reps'), height: 50)),
    SizedBox(width: 8),
    Expanded(child: SizedBox(key: Key('kg'), height: 50)),
    SizedBox(width: 4),
    SizedBox(key: Key('done'), width: 48, height: 48),
  ],
);

Future<void> _pump(WidgetTester tester, double width) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(MaterialApp(home: Scaffold(body: _row())));
}

void main() {
  testWidgets('phones give reps and weight the full row width', (tester) async {
    await _pump(tester, 360);
    final kg = tester.getSize(find.byKey(const Key('kg')));
    expect(kg.width, greaterThan(150));
    final done = tester.getTopLeft(find.byKey(const Key('done')));
    expect(done.dy, greaterThanOrEqualTo(50));
  });

  testWidgets('wide screens keep everything on one line', (tester) async {
    await _pump(tester, 900);
    final reps = tester.getCenter(find.byKey(const Key('reps')));
    final done = tester.getCenter(find.byKey(const Key('done')));
    expect(done.dy, reps.dy);
  });
}
