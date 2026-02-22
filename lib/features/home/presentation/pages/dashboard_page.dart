import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/settings_provider.dart';
import '../providers/home_provider.dart';
import '../providers/next_workout_provider.dart';
import '../providers/dashboard_stats_provider.dart';
import '../widgets/next_workout_card.dart';
import '../widgets/quick_actions_grid.dart';
import '../widgets/weekly_progress_card.dart';
import '../widgets/body_weight_tile.dart';
import '../../../workouts/domain/entities/workout_group_entity.dart';
import '../../../workouts/presentation/providers/workout_provider.dart';
import '../../../workouts/presentation/providers/workout_create_provider.dart';
import '../../../workouts/presentation/widgets/workout_history_card.dart';
import '../../domain/starter_plans.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authNotifierProvider);
    final user = userState.value;
    final settings = ref.watch(settingsProvider);
    final groupsAsync =
        user != null
            ? ref.watch(workoutGroupsProvider(user.id))
            : const AsyncValue<List<WorkoutGroupEntity>>.data([]);

    final logsAsync = ref.watch(allExerciseLogsProvider);
    final exercisesAsync = ref.watch(exercisesProvider);
    final nextWorkoutAsync = ref.watch(nextWorkoutProvider);
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/workouts/create'),
        icon: const Icon(Icons.fitness_center),
        label: const Text('Treino Rápido'),
      ),
      body: CustomScrollView(
        slivers: [
          // Collapsible Header
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                'Treino do dia',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
            ),
            actions: [
               Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: dashboardStatsAsync.when(
                  data: (stats) => Row(
                    children: [
                       const Icon(Icons.local_fire_department, color: Colors.deepOrange, size: 20),
                       const SizedBox(width: 4),
                       Text(
                         '${stats.streak}',
                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                       ),
                       const SizedBox(width: 12),
                    ],
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
            ],
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                 // Custom Greeting Header
                _DashboardHeader(user: user, settings: settings),
                const SizedBox(height: 24),

                // Stats Section
                ref.watch(workoutSummaryProvider).when(
                  data: (summary) => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      dashboardStatsAsync.when(
                        data: (stats) => _SummaryCards(stats: stats),
                        loading: () => const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => const SizedBox.shrink(),
                      ),
                      const SizedBox(height: 24),

                      const WeeklyProgressCard(),
                      const SizedBox(height: 16),
                      const BodyWeightTile(),
                      const SizedBox(height: 32),

                      // Quick Actions Grid
                      const QuickActionsGrid(),
                      const SizedBox(height: 32),

                      // Empty State "Quick Start"
                      if (!summary.hasWorkoutToday) ...[
                        _buildQuickStartCard(context),
                        const SizedBox(height: 24),
                      ],

                      // Active Workout Card
                      if (summary.hasWorkoutToday)
                        _buildActiveWorkoutCard(context, summary)
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Suggest Next Workout
                            nextWorkoutAsync.when(
                              data: (nextGroup) {
                                if (nextGroup != null) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 24),
                                    child: NextWorkoutCard(workoutGroup: nextGroup),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (_, stack) => const SizedBox.shrink(),
                            ),

                            // Last Workout History
                            logsAsync.when(
                              data: (logs) {
                                if (logs.isEmpty) return const SizedBox.shrink();
                                final latestLog = logs.reduce((a, b) => a.date.isAfter(b.date) ? a : b);
                                final latestDate = latestLog.date;
                                final sessionLogs = logs.where((e) =>
                                    e.date.year == latestDate.year &&
                                    e.date.month == latestDate.month &&
                                    e.date.day == latestDate.day).toList();

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Último Treino', style: Theme.of(context).textTheme.titleLarge),
                                    const SizedBox(height: 12),
                                    exercisesAsync.when(
                                      data: (exercises) {
                                        final map = {for (var e in exercises) e.id: e.name};
                                        return WorkoutHistoryCard(
                                          date: latestDate,
                                          logs: sessionLogs,
                                          exerciseNameMap: map,
                                        );
                                      },
                                      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
                                      error: (e, s) => const SizedBox.shrink(),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (e, s) => const SizedBox.shrink(),
                            ),

                            // Plans Section
                            Text('Seus Planos', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: groupsAsync.when(
                                data: (groups) {
                                  if (groups.isEmpty) {
                                    return exercisesAsync.when(
                                      data: (exercises) {
                                        final starters = StarterPlans.getPlans(exercises);
                                        if (starters.isEmpty) {
                                          return _buildCreateNewButton(context);
                                        }
                                        return ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: starters.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index == starters.length) return _buildCreateNewCard(context);
                                            return _buildPlanCard(context, starters[index], isTemplate: true, ref: ref);
                                          },
                                        );
                                      },
                                      loading: () => const Center(child: CircularProgressIndicator()),
                                      error: (e, s) => _buildCreateNewButton(context),
                                    );
                                  }
                                  return ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: groups.length + 1,
                                    itemBuilder: (context, index) {
                                      if (index == groups.length) return _buildCreateNewCard(context);
                                      return _buildPlanCard(context, groups[index], isTemplate: false);
                                    },
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (e, s) => Center(child: Text('Erro: $e')),
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('Erro: $error')),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => context.push('/workouts/create'),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.flash_on, size: 24, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treino Rápido',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sem planos? Inicie agora.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutCard(BuildContext context, dynamic summary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.tertiary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.fitness_center, size: 32, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'HOJE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Próximo Treino',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            summary.workoutName ?? 'Treino Personalizado',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                if (summary.workoutGroupId != null) {
                  context.go('/workouts/${summary.workoutGroupId}');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'INICIAR TREINO',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateNewButton(BuildContext context) {
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => context.push('/workouts/create'),
        icon: const Icon(Icons.add),
        label: const Text('Criar Novo Plano'),
      ),
    );
  }

  Widget _buildCreateNewCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: AspectRatio(
        aspectRatio: 1,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () => context.push('/workouts/create'),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, size: 32, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 8),
                const Text('Criar Novo'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, dynamic plan, {required bool isTemplate, WidgetRef? ref}) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: AspectRatio(
        aspectRatio: 1.2,
        child: Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: InkWell(
            onTap: () {
              if (isTemplate && ref != null) {
                ref.read(workoutCreateProvider.notifier).loadGroup(plan);
                context.push('/workouts/create');
              } else if (!isTemplate) {
                 context.go('/workouts/${plan.id}');
              }
            },
            child: isTemplate
            ? Stack(
                fit: StackFit.expand,
                children: [
                  if (plan.image != null)
                    Opacity(
                      opacity: 0.3,
                      child: Image.asset(plan.image!, fit: BoxFit.cover, errorBuilder: (c, e, s) => const SizedBox()),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'TEMPLATE',
                            style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${plan.workouts.length} exercícios',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.fitness_center,
                        size: 20,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      plan.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${plan.workouts.length} treinos',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
          ),
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.user, required this.settings});

  final dynamic user;
  final dynamic settings;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia';
    if (hour < 18) return 'Boa tarde';
    return 'Boa noite';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Theme.of(context).colorScheme.primary,
          backgroundImage: user?.photoUrl != null
              ? CachedNetworkImageProvider(user!.photoUrl!)
              : null,
          child: user?.photoUrl == null
              ? Text(
                  user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()},',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Text(
              user?.name?.split(' ').first ?? 'Atleta',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final volumeDisplay = stats.volumeThisWeek > 1000
        ? '${(stats.volumeThisWeek / 1000).toStringAsFixed(1)}k'
        : stats.volumeThisWeek.toStringAsFixed(0);

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          _StatCard(
            label: 'Treinos',
            value: '${stats.workoutsThisWeek}/${stats.weeklyGoal}',
            icon: Icons.check_circle_outline,
            color: Colors.blue,
            width: 150,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Volume',
            value: '$volumeDisplay kg',
            icon: Icons.fitness_center,
            color: Colors.orange,
            width: 170,
          ),
          const SizedBox(width: 12),
          // We can add a Duration card here if we had the data
           _StatCard(
            label: 'Sequência',
            value: '${stats.streak} dias',
            icon: Icons.local_fire_department,
            color: Colors.red,
             width: 150,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.width,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
