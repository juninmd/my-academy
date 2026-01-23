import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/home/domain/entities/workout_summary_entity.dart';
import 'package:my_academy/features/home/presentation/providers/home_provider.dart';
import 'package:my_academy/features/profile/presentation/pages/profile_page.dart';
import 'package:my_academy/features/profile/presentation/providers/settings_provider.dart';

class FakeAuthNotifier extends AsyncNotifier<UserEntity?> {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;

  // Need to implement signOut for button test
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
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(
          const UserEntity(id: 'u1', email: 'e', name: 'User Name')
        )),
        settingsProvider.overrideWith(FakeSettingsNotifier.new),
        workoutSummaryProvider.overrideWith((ref) async => const WorkoutSummaryEntity(
            counter: 10,
            hasWorkoutToday: false
        )),
      ],
      child: const MaterialApp(
        home: ProfilePage(),
      ),
    ));
    await tester.pump(); // wait for futures

    expect(find.text('Meu Perfil'), findsOneWidget);
    expect(find.text('User Name'), findsOneWidget);

    // Stats tab default
    expect(find.text('Treinos'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    // Switch tab
    await tester.tap(find.text('Configurações'));
    await tester.pumpAndSettle();

    expect(find.text('Preferências de Treino'), findsOneWidget);
  });
}
