import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/presentation/pages/dashboard_page.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';
import 'package:my_academy/features/home/presentation/providers/dashboard_stats_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('DashboardPage renders static elements and Tools section', (
    WidgetTester tester,
  ) async {
    // Set surface size to avoid RenderFlex overflow during layout
    tester.view.physicalSize = const Size(2000, 3000); // Typical mobile screen size
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            () => FakeAuthNotifier(
              const UserEntity(id: 'u1', email: 'e', name: 'User'),
            ),
          ),
          workoutSummaryProvider.overrideWith(
            (ref) async =>
                const WorkoutSummaryEntity(counter: 5, hasWorkoutToday: false),
          ),
          allExerciseLogsProvider.overrideWith(
            (ref) async => [],
          ), // No logs for history
          dashboardStatsProvider.overrideWith(
            (ref) async => DashboardStats(
              workoutsThisWeek: 2,
              weeklyGoal: 4,
              volumeThisWeek: 500, // Reduced to avoid 'k' formatting
              streak: 3,
            ),
          ),
          exercisesProvider.overrideWith((ref) async => []),
        ],
        child: const MaterialApp(home: DashboardPage()),
      ),
    );

    await tester.pumpAndSettle();

    // Verify App Bar
    expect(find.text('Treino do dia'), findsOneWidget);

    // Verify Quick Stats Row elements
    expect(find.text('Treinos'), findsAtLeastNWidgets(1));
    expect(find.text('2/4'), findsOneWidget); // Workouts/Goal
    expect(find.text('Volume'), findsOneWidget);
    expect(find.text('500 kg'), findsOneWidget); // Volume
    expect(find.text('Sequência'), findsOneWidget);
    expect(find.text('3 dias'), findsOneWidget); // Streak

    // Verify Tools Section (Renamed to Acesso Rápido)
    expect(find.text('Acesso Rápido'), findsOneWidget);

    // Verify "Treino Rápido" card is shown instead of "Descanso Merecido"
    expect(find.text('Treino Rápido'), findsWidgets);
    expect(find.text('Sem planos? Inicie agora.'), findsOneWidget);
  });
}
