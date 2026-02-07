import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/set_log_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/presentation/pages/analytics_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';

void main() {
  setUp(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('AnalyticsPage displays charts and Records tab', (tester) async {
    final logs = [
      ExerciseLogEntity(
        id: '1',
        userId: 'u1',
        exerciseId: 1,
        date: DateTime.now(),
        sets: const [SetLogEntity(reps: 10, weight: 50)],
      ),
    ];
    final exercises = [
       ExerciseEntity(id: 1, name: 'Agachamento', tips: [], mistakes: []),
    ];

    await tester.pumpWidget(ProviderScope(
      overrides: [
        allExerciseLogsProvider.overrideWith((ref) async => logs),
        exercisesProvider.overrideWith((ref) async => exercises),
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

    // Verify Tabs
    expect(find.text('Progresso'), findsOneWidget);
    expect(find.text('Recordes'), findsOneWidget);

    // Verify Charts (First Tab)
    expect(find.text('Séries Realizadas'), findsOneWidget);

    // Tap Records Tab
    await tester.tap(find.text('Recordes'));
    await tester.pumpAndSettle();

    // Verify Records List
    expect(find.text('Agachamento'), findsOneWidget);
    expect(find.text('1RM Est.'), findsOneWidget);
  });
}
