import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:my_academy/features/auth/domain/entities/user_entity.dart';
import 'package:my_academy/features/home/presentation/providers/dashboard_stats_provider.dart';
import 'package:my_academy/features/home/presentation/widgets/dashboard/pulse_greeting.dart';
import 'package:my_academy/features/home/presentation/widgets/dashboard/weekly_pulse_card.dart';
import 'package:my_academy/features/home/presentation/widgets/pulse_hero_card.dart';
import 'package:my_academy/features/workouts/presentation/widgets/rest_timer_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('greeting follows the clock', () {
    expect(PulseGreeting.greetingFor(7), 'Bom dia');
    expect(PulseGreeting.greetingFor(14), 'Boa tarde');
    expect(PulseGreeting.greetingFor(21), 'Boa noite');
  });

  testWidgets('greeting shows first name and streak', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const PulseGreeting(
          user: UserEntity(id: 'u', email: 'e', name: 'Ana Souza'),
          streak: 5,
        ),
      ),
    );
    expect(find.textContaining('Ana.'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.bySemanticsLabel('Sequência de 5 dias'), findsOneWidget);
  });

  test('volume is shortened above a ton', () {
    expect(WeeklyPulseCard.formatVolume(850), '850');
    expect(WeeklyPulseCard.formatVolume(12345), '12.3k');
  });

  testWidgets('weekly card celebrates a hit goal', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeeklyPulseCard(
          stats: DashboardStats(
            workoutsThisWeek: 4,
            weeklyGoal: 4,
            volumeThisWeek: 2500,
            streak: 9,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Meta da semana batida'), findsOneWidget);
    expect(find.text('4/4'), findsOneWidget);
    expect(find.text('2.5k kg'), findsOneWidget);
    expect(find.text('9 dias'), findsOneWidget);
  });

  testWidgets('weekly card tolerates a zero goal', (tester) async {
    await tester.pumpWidget(
      _wrap(
        WeeklyPulseCard(
          stats: DashboardStats(
            workoutsThisWeek: 0,
            weeklyGoal: 0,
            volumeThisWeek: 0,
            streak: 0,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0/0'), findsOneWidget);
  });

  testWidgets('hero card shows tag and fires its action', (tester) async {
    var started = false;
    await tester.pumpWidget(
      _wrap(
        PulseHeroCard(
          eyebrow: 'Treino de hoje',
          tag: 'Peito',
          title: 'Treino A',
          subtitle: 'Sessão programada',
          actionLabel: 'Iniciar agora',
          onAction: () => started = true,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('TREINO DE HOJE'), findsOneWidget);
    expect(find.text('PEITO'), findsOneWidget);
    await tester.tap(find.text('Iniciar agora'));
    await tester.pumpAndSettle();
    expect(started, isTrue);
  });

  test('rest clock switches to minutes past 59s', () {
    expect(RestTimerWidget.format(45), '45');
    expect(RestTimerWidget.format(90), '1:30');
  });

  testWidgets('rest panel offers +30s when provided', (tester) async {
    var added = false;
    await tester.pumpWidget(
      _wrap(
        RestTimerWidget(
          remainingSeconds: 0,
          totalSeconds: 0,
          onAdd10Seconds: () {},
          onAdd30Seconds: () => added = true,
          onSkip: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Vamos!'), findsOneWidget);
    await tester.tap(find.text('+30s'));
    expect(added, isTrue);
  });
}
