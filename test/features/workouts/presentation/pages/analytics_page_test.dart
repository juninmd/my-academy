import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/analytics_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

void main() {
  setUp(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('AnalyticsPage displays charts', (tester) async {
    final logs = [
      ExerciseLogEntity(
        id: '1',
        userId: 'u1',
        exerciseId: 1,
        date: DateTime.now(),
        sets: const [SetLogEntity(reps: 10, weight: 50)],
      ),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [
        allExerciseLogsProvider.overrideWith((ref) async => logs),
      ],
      child: const MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [Locale('pt', 'BR')],
        home: AnalyticsPage(),
      ),
    ));

    // Wait for data
    await tester.pumpAndSettle();

    expect(find.text('Análise de Progresso'), findsOneWidget);
    expect(find.text('Séries Realizadas - Últimos 7 dias'), findsOneWidget);
    expect(find.text('Volume (Toneladas) - Últimos 7 dias'), findsOneWidget);
  });
}
