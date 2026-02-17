import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/home/presentation/widgets/quick_timer_dialog.dart';

void main() {
  testWidgets('QuickTimerDialog starts timer', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: QuickTimerDialog())),
    );

    expect(find.text('Descanso Rápido'), findsOneWidget);

    // Find Start button
    final startButton = find.text('Iniciar');
    expect(startButton, findsOneWidget);

    await tester.tap(startButton);
    await tester.pump();

    expect(find.byIcon(Icons.stop), findsOneWidget);

    await tester.tap(find.byIcon(Icons.stop));
    await tester.pump();

    expect(find.text('Iniciar'), findsOneWidget);
  });
}
