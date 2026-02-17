import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/widgets/rpe_info_dialog.dart';

void main() {
  testWidgets('RpeInfoDialog displays scale', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: RpeInfoDialog()));

    expect(find.textContaining('Escala RPE'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('Esforço Máximo'), findsOneWidget);
  });
}
