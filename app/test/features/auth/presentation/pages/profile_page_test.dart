import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/gym/domain/entities/gym_entities.dart';
import 'package:my_academy/features/gym/presentation/providers/gym_providers.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';
import 'package:my_academy/features/auth/presentation/pages/profile_page.dart';
import 'package:my_academy/features/profile/presentation/providers/settings_provider.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_create_provider.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

class FakeAuthNotifier extends AuthNotifier {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;

  @override
  Future<void> signOut() async {
    state = const AsyncValue.data(null);
  }
}

class FakeSettingsNotifier extends SettingsNotifier {
  @override
  SettingsState build() => SettingsState();
}

void main() {
  testWidgets('ProfilePage displays info', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(
            () => FakeAuthNotifier(
              const UserEntity(id: 'u1', email: 'e', name: 'User Name'),
            ),
          ),
          settingsProvider.overrideWith(FakeSettingsNotifier.new),
          myMembershipsProvider.overrideWith(
            (ref) async => const [
              MembershipEntity(
                gymName: 'Academia Centro',
                status: 'ACTIVE',
                planName: 'Mensal',
                pendingPayments: 1,
              ),
            ],
          ),
          // This is likely not used anymore in ProfilePage but keeping it
          workoutSummaryProvider.overrideWith(
            (ref) async =>
                const WorkoutSummaryEntity(counter: 10, hasWorkoutToday: false),
          ),
          // Overrides for ProfilePage
          allExerciseLogsProvider.overrideWith(
            (ref) async => [
              ExerciseLogEntity(
                userId: 'u1',
                exerciseId: 1,
                date: DateTime.now(),
                sets: [],
              ),
            ],
          ),
          exercisesProvider.overrideWith(
            (ref) async => [const ExerciseEntity(id: 1, name: 'Bench Press')],
          ),
        ],
        child: const MaterialApp(home: ProfilePage()),
      ),
    );
    await tester.pumpAndSettle(); // wait for futures

    expect(find.text('Perfil'), findsOneWidget);
    expect(find.text('e'), findsOneWidget);

    // We expect a textfield initialized with the username
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);
    expect(tester.widget<TextField>(textField).controller?.text, 'User Name');

    // The student sees the enrollment the gym owner registered.
    expect(find.text('Academia Centro'), findsOneWidget);
    expect(find.text('Mensal · 1 pagamento(s) em aberto'), findsOneWidget);
  });
}
