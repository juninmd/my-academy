import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/workouts/presentation/pages/workout_groups_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';

class FakeAuthNotifier extends AsyncNotifier<UserEntity?> {
  final UserEntity? _initial;
  FakeAuthNotifier(this._initial);
  @override
  Future<UserEntity?> build() async => _initial;
}

void main() {
  testWidgets('WorkoutGroupsPage displays empty state', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith(() => FakeAuthNotifier(
          const UserEntity(id: 'u1', email: 'e', name: 'n')
        )),
        workoutGroupsProvider.overrideWith((ref, id) async => []),
      ],
      child: const MaterialApp(
        home: WorkoutGroupsPage(),
      ),
    ));
    await tester.pump();

    expect(find.text('Nenhum treino encontrado'), findsOneWidget);
    expect(find.text('Criar Treino'), findsOneWidget);
  });
}
