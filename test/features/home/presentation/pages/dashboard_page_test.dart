import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/home/presentation/pages/dashboard_page.dart';

// We need to override providers to provide dummy data for the Dashboard
// Since we can't easily import the Entity classes without seeing them,
// we will rely on the UI handling 'loading' or 'error' states,
// OR we will assume the default state of providers if they are auto-dispose/initialized.

// However, testing the "Tools" section doesn't require backend data if it's static.
// The stats section depends on `workoutSummaryProvider`.

void main() {
  testWidgets('DashboardPage renders static elements and Tools section', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    // Verify App Bar
    expect(find.text('Treino do dia'), findsOneWidget);

    // Verify Tools Section
    expect(find.text('Ferramentas'), findsOneWidget);
    expect(find.text('Anilhas'), findsOneWidget);
    expect(find.text('1RM'), findsOneWidget);
    expect(find.text('Descanso'), findsOneWidget);
  });

  testWidgets('DashboardPage opens Plate Calculator when tool tapped', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    await tester.tap(find.text('Anilhas'));
    await tester.pumpAndSettle();

    expect(find.text('Calculadora de Anilhas'), findsOneWidget);
  });
}
