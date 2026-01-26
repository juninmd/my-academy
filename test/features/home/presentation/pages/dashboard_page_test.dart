import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/presentation/pages/dashboard_page.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  testWidgets('DashboardPage renders static elements and Tools section', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier(
            const UserEntity(id: 'u1', email: 'e', name: 'User')
          )),
          workoutSummaryProvider.overrideWith((ref) async => const WorkoutSummaryEntity(
            counter: 5,
            hasWorkoutToday: false,
          )),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify App Bar
    expect(find.text('Treino do dia'), findsOneWidget);

    // Verify Tools Section
    expect(find.text('Ferramentas'), findsOneWidget);
    expect(find.text('Anilhas'), findsOneWidget);
    expect(find.text('1RM'), findsOneWidget);
    expect(find.text('Timer'), findsOneWidget); // Changed form Descanso to Timer
  });

  testWidgets('DashboardPage opens Plate Calculator when tool tapped', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => FakeAuthNotifier(
            const UserEntity(id: 'u1', email: 'e', name: 'User')
          )),
           workoutSummaryProvider.overrideWith((ref) async => const WorkoutSummaryEntity(
            counter: 5,
            hasWorkoutToday: false,
          )),
        ],
        child: const MaterialApp(
          home: DashboardPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final finder = find.text('Anilhas');
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();

    await tester.tap(finder);
    await tester.pumpAndSettle();

    expect(find.text('Calculadora de Anilhas'), findsOneWidget);
  });
}
