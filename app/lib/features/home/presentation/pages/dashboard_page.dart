import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/pulse/pulse_entrance.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/dashboard_stats_provider.dart';
import '../providers/home_provider.dart';
import '../providers/next_workout_provider.dart';
import '../widgets/body_weight_tile.dart';
import '../widgets/daily_insight_card.dart';
import '../widgets/daily_note_card.dart';
import '../widgets/dashboard/last_workout_section.dart';
import '../widgets/dashboard/plans_carousel.dart';
import '../widgets/dashboard/pulse_greeting.dart';
import '../widgets/dashboard/quick_start_card.dart';
import '../widgets/dashboard/today_workout_card.dart';
import '../widgets/dashboard/weekly_pulse_card.dart';
import '../widgets/next_workout_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/recent_progress_chart.dart';
import '../widgets/weekly_progress_card.dart';

/// "Hoje": o cockpit do aluno.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).value;
    final stats = ref.watch(dashboardStatsProvider);
    final summaryAsync = ref.watch(workoutSummaryProvider);
    final next = ref.watch(nextWorkoutProvider).value;

    final List<Widget> sections = summaryAsync.when(
      data: (summary) => [
        if (summary.hasWorkoutToday)
          TodayWorkoutCard(summary: summary)
        else ...[
          if (next != null) NextWorkoutCard(workoutGroup: next),
          const QuickStartCard(),
        ],
        stats.when(
          data: (s) => WeeklyPulseCard(stats: s),
          loading: () => const SizedBox(
            height: 124,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
        const DailyInsightCard(),
        const RecentProgressChart(),
        const WeeklyProgressCard(),
        const BodyWeightTile(),
        const DailyNoteCard(),
        const QuickActionsGrid(),
        if (!summary.hasWorkoutToday) ...[
          const LastWorkoutSection(),
          PlansCarousel(userId: user?.id),
        ],
      ],
      loading: () => [const Center(child: CircularProgressIndicator())],
      error: (e, _) => [Center(child: Text('Erro: $e'))],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  toolbarHeight: 48,
                  title: const Text('Treino do dia'),
                  titleTextStyle: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  sliver: SliverList.separated(
                    itemCount: sections.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, i) {
                      final child = i == 0
                          ? PulseGreeting(
                              user: user,
                              streak: stats.value?.streak,
                            )
                          : sections[i - 1];
                      return child.pulseIn(i);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
