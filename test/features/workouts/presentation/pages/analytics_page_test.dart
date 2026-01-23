import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/workouts/presentation/pages/analytics_page.dart';

void main() {
  testWidgets('AnalyticsPage displays charts', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AnalyticsPage(),
    ));

    expect(find.text('Análise de Progresso'), findsOneWidget);
    expect(find.text('Treinos por Semana'), findsOneWidget);
    expect(find.text('Volume Estimado (Ton)'), findsOneWidget);
  });
}
