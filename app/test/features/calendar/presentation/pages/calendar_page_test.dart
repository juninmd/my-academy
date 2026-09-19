import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_academy/features/calendar/data/repositories/calendar_repository.dart';
import 'package:my_academy/features/calendar/domain/entities/workout_session_entity.dart';
import 'package:my_academy/features/calendar/presentation/pages/calendar_page.dart';
import 'package:my_academy/features/workouts/presentation/providers/workout_provider.dart';
import 'package:my_academy/features/workouts/domain/entities/workout_group_entity.dart';
import 'package:my_academy/features/workouts/domain/entities/exercise_log_entity.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUp(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  testWidgets('CalendarPage renders correctly', (WidgetTester tester) async {
    // Mock user
    const user = UserEntity(
      id: 'user1',
      name: 'User 1',
      email: 'user1@example.com',
    );

    final now = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authNotifierProvider.overrideWith(() => MockAuthNotifier(user)),
          // Provide specific override for the current month view
          workoutSessionsProvider('user1', now.month, now.year).overrideWith((
            ref,
          ) async {
            return [
              WorkoutSessionEntity(
                workoutGroupId: 1,
                date: now,
                checked: true,
                userId: 'user1',
                createdAt: DateTime(now.year, now.month, now.day, 7, 30),
              ),
            ];
          }),
          workoutGroupsProvider(
            'user1',
          ).overrideWith((ref) async => <WorkoutGroupEntity>[]),
          allExerciseLogsProvider.overrideWith(
            (ref) async => <ExerciseLogEntity>[],
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [Locale('pt', 'BR')],
          home: CalendarPage(),
        ),
      ),
    );

    // Initial load might show indicator
    await tester.pump();

    // Verify AppBar
    expect(find.text('Calendário'), findsOneWidget);

    // Wait for async
    await tester.pumpAndSettle();

    // Shows when it was logged, not the day-only midnight of date.
    expect(find.text('Realizado às 07:30'), findsOneWidget);
    // The format toggle had no handler; it must not be offered.
    expect(find.text('2 weeks'), findsNothing);
  });
}

// Mock Auth Notifier
class MockAuthNotifier extends AuthNotifier {
  final UserEntity? _initialUser;

  MockAuthNotifier(this._initialUser);

  @override
  Future<UserEntity?> build() async {
    return _initialUser;
  }
}
